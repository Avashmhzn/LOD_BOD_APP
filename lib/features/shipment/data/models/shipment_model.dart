import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_status_event.dart';


class ShipmentModel extends ShipmentEntity {
  const ShipmentModel({
    required super.id,
    super.reference,
    super.pickupLocation,
    super.deliveryLocation,
    super.cargoDescription,
    super.cargoCategory,
    super.weight,
    super.weightUnit,
    super.weightKg,
    super.vehicleType,
    super.pickupAt,
    super.expectedFare,
    super.contactNumber,
    super.notes,
    super.createdBy,
    super.status,
    super.bidCount,
    super.createdAt,
    super.updatedAt,
    super.biddingClosesAt,
    super.bids,
    super.acceptedBid,
    super.assignedCarrier,
    super.statusHistory,
    super.extraData,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json);
    final knownKeys = {
      'id',
      'reference',
      'pickupLocation',
      'deliveryLocation',
      'cargoDescription',
      'cargoCategory',
      'weight',
      'weightUnit',
      'weightKg',
      'vehicleType',
      'pickupAt',
      'pickupDate',
      'expectedFare',
      'contactNumber',
      'notes',
      'createdBy',
      'status',
      'bidCount',
      'createdAt',
      'updatedAt',
      'biddingClosesAt',
      'bidEndsAt',
      'bids',
      'acceptedBid',
      'assignedCarrier',
      'statusHistory',
    };
    final rawBids = data['bids'];
    final rawAcceptedBid = data['acceptedBid'];
    final rawHistory = data['statusHistory'];

    return ShipmentModel(
      id: data['id']?.toString() ?? '',
      reference: _string(data['reference']),
      pickupLocation: _string(data['pickupLocation']),
      deliveryLocation: _string(data['deliveryLocation']),
      cargoDescription: _string(data['cargoDescription']),
      cargoCategory: _string(data['cargoCategory']),
      weight: _number(data['weight']),
      weightUnit: _string(data['weightUnit']),
      weightKg: _number(data['weightKg']),
      vehicleType: _string(data['vehicleType']),
      pickupAt: _date(data['pickupAt'] ?? data['pickupDate']),
      expectedFare: _number(data['expectedFare']),
      contactNumber: _string(data['contactNumber']),
      notes: _string(data['notes']),
      createdBy: _string(data['createdBy']),
      status: _string(data['status']) ?? 'pending',
      bidCount: _integer(data['bidCount']) ?? 0,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
      biddingClosesAt: _date(data['biddingClosesAt'] ?? data['bidEndsAt']),
      bids: rawBids is List
          ? rawBids.whereType<Map>().map(_bidFromMap).toList()
          : const [],
      acceptedBid: rawAcceptedBid is Map ? _bidFromMap(rawAcceptedBid) : null,
      assignedCarrier: _string(data['assignedCarrier']),
      statusHistory: rawHistory is List
          ? rawHistory.whereType<Map>().map(_eventFromMap).toList()
          : const [],
      extraData: Map.fromEntries(
        data.entries.where((entry) => !knownKeys.contains(entry.key)),
      ),
    );
  }

  factory ShipmentModel.fromEntity(ShipmentEntity entity) => ShipmentModel(
    id: entity.id,
    reference: entity.reference,
    pickupLocation: entity.pickupLocation,
    deliveryLocation: entity.deliveryLocation,
    cargoDescription: entity.cargoDescription,
    cargoCategory: entity.cargoCategory,
    weight: entity.weight,
    weightUnit: entity.weightUnit,
    weightKg: entity.weightKg,
    vehicleType: entity.vehicleType,
    pickupAt: entity.pickupAt,
    expectedFare: entity.expectedFare,
    contactNumber: entity.contactNumber,
    notes: entity.notes,
    createdBy: entity.createdBy,
    status: entity.status,
    bidCount: entity.bidCount,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    biddingClosesAt: entity.biddingClosesAt,
    bids: entity.bids,
    acceptedBid: entity.acceptedBid,
    assignedCarrier: entity.assignedCarrier,
    statusHistory: entity.statusHistory,
    extraData: entity.extraData,
  );

  Map<String, dynamic> toJson() => {
    ...extraData,
    'id': id,
    'reference': reference,
    'pickupLocation': pickupLocation,
    'deliveryLocation': deliveryLocation,
    'cargoDescription': cargoDescription,
    'cargoCategory': cargoCategory,
    'weight': weight,
    'weightUnit': weightUnit,
    'weightKg': weightKg,
    'vehicleType': vehicleType,
    'pickupAt': pickupAt,
    'expectedFare': expectedFare,
    'contactNumber': contactNumber,
    'notes': notes,
    'createdBy': createdBy,
    'status': status,
    'bidCount': bidCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'biddingClosesAt': biddingClosesAt,
    'bids': bids.map(_bidToMap).toList(),
    'acceptedBid': acceptedBid == null ? null : _bidToMap(acceptedBid!),
    'assignedCarrier': assignedCarrier,
    'statusHistory': statusHistory.map(_eventToMap).toList(),
  };

  static ShipmentBidEntity _bidFromMap(Map bid) => ShipmentBidEntity(
    id: bid['id']?.toString() ?? '',
    carrier: bid['carrier']?.toString() ?? 'Carrier',
    fare: _number(bid['fare']) ?? 0,
    rating: _number(bid['rating']) ?? 0,
    deliveryDays: _integer(bid['deliveryDays']) ?? 0,
    status: bid['status']?.toString(),
  );

  static Map<String, dynamic> _bidToMap(ShipmentBidEntity bid) => {
    'id': bid.id,
    'carrier': bid.carrier,
    'fare': bid.fare,
    'rating': bid.rating,
    'deliveryDays': bid.deliveryDays,
    if (bid.status != null) 'status': bid.status,
  };

  static ShipmentStatusEvent _eventFromMap(Map event) => ShipmentStatusEvent(
    status: event['status']?.toString() ?? 'Status updated',
    at: _date(event['at']),
    note: event['note']?.toString(),
    location: event['location']?.toString(),
  );

  static Map<String, dynamic> _eventToMap(ShipmentStatusEvent event) => {
    'status': event.status,
    'at': event.at,
    if (event.note != null) 'note': event.note,
    if (event.location != null) 'location': event.location,
  };

  static String? _string(dynamic value) => value?.toString();

  static double? _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  static int? _integer(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

  static DateTime? _date(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value != null && value is! String) {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {}
    }
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
