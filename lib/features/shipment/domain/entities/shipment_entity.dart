import 'package:equatable/equatable.dart';

import 'shipment_bid_entity.dart';
import 'shipment_status_event.dart';

class ShipmentEntity extends Equatable {
  const ShipmentEntity({
    required this.id,
    this.reference,
    this.pickupLocation,
    this.deliveryLocation,
    this.cargoDescription,
    this.cargoCategory,
    this.weight,
    this.weightUnit,
    this.weightKg,
    this.vehicleType,
    this.pickupAt,
    this.expectedFare,
    this.contactNumber,
    this.notes,
    this.createdBy,
    this.status = 'pending',
    this.bidCount = 0,
    this.createdAt,
    this.updatedAt,
    this.biddingClosesAt,
    this.bids = const [],
    this.acceptedBid,
    this.assignedCarrier,
    this.statusHistory = const [],
    this.extraData = const {},
  });

  final String id;
  final String? reference;
  final String? pickupLocation;
  final String? deliveryLocation;
  final String? cargoDescription;
  final String? cargoCategory;
  final double? weight;
  final String? weightUnit;
  final double? weightKg;
  final String? vehicleType;
  final DateTime? pickupAt;
  final double? expectedFare;
  final String? contactNumber;
  final String? notes;
  final String? createdBy;
  final String status;
  final int bidCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? biddingClosesAt;
  final List<ShipmentBidEntity> bids;
  final ShipmentBidEntity? acceptedBid;
  final String? assignedCarrier;
  final List<ShipmentStatusEvent> statusHistory;
  final Map<String, dynamic> extraData;

  ShipmentEntity copyWith({
    String? status,
    int? bidCount,
    DateTime? updatedAt,
    double? expectedFare,
    List<ShipmentBidEntity>? bids,
    ShipmentBidEntity? acceptedBid,
    String? assignedCarrier,
    List<ShipmentStatusEvent>? statusHistory,
  }) => ShipmentEntity(
    id: id,
    reference: reference,
    pickupLocation: pickupLocation,
    deliveryLocation: deliveryLocation,
    cargoDescription: cargoDescription,
    cargoCategory: cargoCategory,
    weight: weight,
    weightUnit: weightUnit,
    weightKg: weightKg,
    vehicleType: vehicleType,
    pickupAt: pickupAt,
    expectedFare: expectedFare ?? this.expectedFare,
    contactNumber: contactNumber,
    notes: notes,
    createdBy: createdBy,
    status: status ?? this.status,
    bidCount: bidCount ?? this.bidCount,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    biddingClosesAt: biddingClosesAt,
    bids: bids ?? this.bids,
    acceptedBid: acceptedBid ?? this.acceptedBid,
    assignedCarrier: assignedCarrier ?? this.assignedCarrier,
    statusHistory: statusHistory ?? this.statusHistory,
    extraData: extraData,
  );

  @override
  List<Object?> get props => [
    id,
    reference,
    pickupLocation,
    deliveryLocation,
    cargoDescription,
    cargoCategory,
    weight,
    weightUnit,
    weightKg,
    vehicleType,
    pickupAt,
    expectedFare,
    contactNumber,
    notes,
    createdBy,
    status,
    bidCount,
    createdAt,
    updatedAt,
    biddingClosesAt,
    bids,
    acceptedBid,
    assignedCarrier,
    statusHistory,
    extraData,
  ];
}
