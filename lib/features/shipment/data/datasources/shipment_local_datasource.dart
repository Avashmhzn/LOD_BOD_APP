import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lodbod_app/core/error/exceptions.dart';
import 'package:lodbod_app/core/utils/logger.dart';
import 'package:lodbod_app/features/shipment/data/models/shipment_model.dart';

abstract class ShipmentLocalDataSource {
  Future<List<ShipmentModel>> getCachedShipments();
  Future<void> cacheShipments(List<ShipmentModel> shipments);
  Future<ShipmentModel?> getCachedShipment(String id);
  Future<void> cacheShipment(ShipmentModel shipment);
  Future<void> clearCache();
}

class ShipmentLocalDataSourceImpl implements ShipmentLocalDataSource {
  static const String _boxName = 'shipments';
  String get _shipmentsKey =>
      'all_shipments_${FirebaseAuth.instance.currentUser?.uid ?? 'signed_out'}';

  Map<String, dynamic> _toHiveMap(Map<String, dynamic> data) =>
      data.map((key, value) => MapEntry(key, _toHiveValue(value)));

  dynamic _toHiveValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is Map) {
      return value.map<dynamic, dynamic>(
        (key, nestedValue) => MapEntry(key, _toHiveValue(nestedValue)),
      );
    }
    if (value is List) return value.map(_toHiveValue).toList();
    return value;
  }

  @override
  Future<List<ShipmentModel>> getCachedShipments() async {
    try {
      final box = await Hive.openBox<dynamic>(_boxName);
      final data = box.get(_shipmentsKey);

      if (data is! List) return [];

      return data
          .map(
            (json) =>
                ShipmentModel.fromJson(Map<String, dynamic>.from(json as Map)),
          )
          .toList();
    } catch (e) {
      AppLogger.error('Error reading cached shipments', e);
      throw CacheException('Failed to read cache');
    }
  }

  @override
  Future<void> cacheShipments(List<ShipmentModel> shipments) async {
    try {
      final box = await Hive.openBox<dynamic>(_boxName);
      final data = shipments.map((s) => _toHiveMap(s.toJson())).toList();
      await box.put(_shipmentsKey, data);
      AppLogger.debug('Cached ${shipments.length} shipments');
    } catch (e) {
      AppLogger.error('Error caching shipments', e);
    }
  }

  @override
  Future<ShipmentModel?> getCachedShipment(String id) async {
    try {
      final box = await Hive.openBox<dynamic>(_boxName);
      final json = box.get('shipment_$id');
      return json is Map
          ? ShipmentModel.fromJson(Map<String, dynamic>.from(json))
          : null;
    } catch (e) {
      AppLogger.error('Error reading cached shipment', e);
      return null;
    }
  }

  @override
  Future<void> cacheShipment(ShipmentModel shipment) async {
    try {
      final box = await Hive.openBox<dynamic>(_boxName);
      await box.put('shipment_${shipment.id}', _toHiveMap(shipment.toJson()));
    } catch (e) {
      AppLogger.error('Error caching shipment', e);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox<dynamic>(_boxName);
      await box.clear();
    } catch (e) {
      AppLogger.error('Error clearing cache', e);
    }
  }
}
