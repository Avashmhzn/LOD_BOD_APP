import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:lodbod_app/core/error/exceptions.dart';
import 'package:lodbod_app/features/shipment/data/models/shipment_model.dart';
import 'package:lodbod_app/features/shipment/domain/utils/shipment_reference.dart';
import 'sample_bid_fixtures.dart';
import 'sample_shipment_fixtures.dart';

abstract class ShipmentRemoteDataSource {
  Future<List<ShipmentModel>> getShipments();
  Future<ShipmentModel> createShipment(ShipmentModel shipment);
  Future<ShipmentModel> updateShipment(ShipmentModel shipment);
  Future<ShipmentModel> placeBid({
    required String shipmentId,
    required double fare,
    required int deliveryDays,
  });
  Future<ShipmentModel> acceptBid({
    required String shipmentId,
    required String bidId,
  });
}

class ShipmentRemoteDataSourceImpl implements ShipmentRemoteDataSource {
  static const _seedDemoFixtures = bool.fromEnvironment('ENABLE_DEMO_FIXTURES');

  ShipmentRemoteDataSourceImpl({
    required this._firestore,
    required this._functions,
  });

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _shipments =>
      _firestore.collection('shipments');

  @override
  Future<List<ShipmentModel>> getShipments() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return [];

      final profile = await _firestore.collection('users').doc(uid).get();
      final isCarrier = profile.data()?['role'] == 'carrier';
      final query = isCarrier
          ? _shipments.where(
              'status',
              whereIn: const ['pending', 'awaiting_bids'],
            )
          : _shipments.where('createdBy', isEqualTo: uid);
      var snapshot = await query.get();
      if (snapshot.docs.isEmpty && _seedDemoFixtures && !isCarrier) {
        await _seedDemoShipments(uid);
        snapshot = await query.get();
      }
      return snapshot.docs
          .map(
            (document) =>
                ShipmentModel.fromJson({...document.data(), 'id': document.id}),
          )
          .toList();
    } on FirebaseException catch (error) {
      throw ServerException(error.message ?? 'Failed to fetch shipments');
    }
  }

  Future<void> _seedDemoShipments(String userId) async {
    final fixtures = SampleShipmentFixtures.forUser(userId);
    final userDocument = _firestore.collection('users').doc(userId);
    final batch = _firestore.batch();
    for (final fixture in fixtures) {
      final document = _shipments.doc(fixture.id);
      final data = fixture.toJson()..remove('id');
      batch.set(document, data);
    }
    batch.set(userDocument, {
      'demoFixturesSeeded': true,
      'lastShipmentReferenceNumber': 1004,
    }, SetOptions(merge: true));
    await batch.commit();
  }

  @override
  Future<ShipmentModel> createShipment(ShipmentModel shipment) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw const ServerException('Sign in before creating a shipment');
      }
      if (shipment.createdBy != null && shipment.createdBy != userId) {
        throw const ServerException(
          'Cannot create a shipment for another account',
        );
      }

      final data = shipment.toJson()..remove('id');
      data['createdBy'] = userId;
      final shipmentDocument = _shipments.doc(
        shipment.id.isEmpty ? null : shipment.id,
      );
      if (shipment.status.toLowerCase() != 'draft') {
        return await _createNumberedShipment(
          shipment,
          data,
          userId,
          shipmentDocument,
        );
      }

      return await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(shipmentDocument);
        if (existing.exists) return _existingShipment(existing, userId);

        transaction.set(shipmentDocument, data);
        return ShipmentModel.fromJson({...data, 'id': shipmentDocument.id});
      });
    } on FirebaseException catch (error) {
      throw ServerException(error.message ?? 'Failed to create shipment');
    }
  }

  ShipmentModel _existingShipment(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String userId,
  ) {
    final data = snapshot.data()!;
    if (data['createdBy'] != userId) {
      throw const ServerException(
        'This shipment request has already been used',
      );
    }
    return ShipmentModel.fromJson({...data, 'id': snapshot.id});
  }

  Future<ShipmentModel> _createNumberedShipment(
    ShipmentModel shipment,
    Map<String, dynamic> data,
    String userId,
    DocumentReference<Map<String, dynamic>> shipmentDocument,
  ) async {
    final existingShipments = await _shipments
        .where('createdBy', isEqualTo: userId)
        .get();
    final references = existingShipments.docs.map(
      (document) => document.data()['reference']?.toString(),
    );
    final reference = ShipmentReference.next(references);
    final shipmentData = {...data, 'reference': reference, 'createdBy': userId};
    await shipmentDocument.set(shipmentData);

    return ShipmentModel.fromJson({...shipmentData, 'id': shipmentDocument.id});
  }

  @override
  Future<ShipmentModel> updateShipment(ShipmentModel shipment) async {
    try {
      final data = shipment.toJson()..remove('id');
      await _shipments.doc(shipment.id).update(data);
      return shipment;
    } on FirebaseException catch (error) {
      throw ServerException(error.message ?? 'Failed to update shipment');
    }
  }

  @override
  Future<ShipmentModel> placeBid({
    required String shipmentId,
    required double fare,
    required int deliveryDays,
  }) async {
    try {
      await _functions.httpsCallable('placeShipmentBid').call({
        'shipmentId': shipmentId,
        'fare': fare,
        'deliveryDays': deliveryDays,
      });
      final snapshot = await _shipments.doc(shipmentId).get();
      if (!snapshot.exists) throw const ServerException('Shipment not found');
      return ShipmentModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
    } on FirebaseFunctionsException catch (error) {
      throw ServerException(error.message ?? 'Failed to place bid');
    } on FirebaseException catch (error) {
      throw ServerException(error.message ?? 'Failed to load updated shipment');
    }
  }

  @override
  Future<ShipmentModel> acceptBid({
    required String shipmentId,
    required String bidId,
  }) => _acceptBidWithFirestore(shipmentId: shipmentId, bidId: bidId);

  Future<ShipmentModel> _acceptBidWithFirestore({
    required String shipmentId,
    required String bidId,
  }) async {
    final shipmentRef = _shipments.doc(shipmentId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(shipmentRef);
        if (!snapshot.exists) {
          throw const ServerException('Shipment not found');
        }

        final shipment = snapshot.data()!;
        final currentAcceptedBid = shipment['acceptedBid'];
        if (currentAcceptedBid is Map && currentAcceptedBid['id'] == bidId) {
          return;
        }

        final status = (shipment['status']?.toString() ?? '')
            .toLowerCase()
            .replaceAll('_', ' ');
        if (status != 'pending' && status != 'awaiting bids') {
          throw const ServerException('This shipment is no longer open.');
        }

        final rawBids = shipment['bids'];
        final storedBid = rawBids is List
            ? rawBids
                  .whereType<Map>()
                  .where((bid) => bid['id']?.toString() == bidId)
                  .firstOrNull
            : null;
        Map<String, dynamic>? selectedBid = storedBid == null
            ? null
            : Map<String, dynamic>.from(storedBid);
        if (selectedBid == null &&
            (rawBids == null || (rawBids is List && rawBids.isEmpty))) {
          final fixture = SampleBidFixtures.assessmentBids
              .where((bid) => bid.id == bidId)
              .firstOrNull;
          if (fixture != null) {
            selectedBid = {
              'id': fixture.id,
              'carrier': fixture.carrier,
              'fare': fixture.fare,
              'rating': fixture.rating,
              'deliveryDays': fixture.deliveryDays,
            };
          }
        }
        if (selectedBid == null) {
          throw const ServerException('Bid not found');
        }

        transaction.update(shipmentRef, {
          'acceptedBid': selectedBid,
          'assignedCarrier': selectedBid['carrier'],
          'expectedFare': selectedBid['fare'],
          'status': 'scheduled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      final snapshot = await shipmentRef.get();
      if (!snapshot.exists) throw const ServerException('Shipment not found');
      return ShipmentModel.fromJson({...snapshot.data()!, 'id': snapshot.id});
    } on FirebaseException catch (error) {
      throw ServerException(error.message ?? 'Failed to accept bid');
    }
  }
}
