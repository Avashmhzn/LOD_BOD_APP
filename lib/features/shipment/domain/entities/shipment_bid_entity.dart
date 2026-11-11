import 'package:equatable/equatable.dart';

class ShipmentBidEntity extends Equatable {
  const ShipmentBidEntity({
    required this.id,
    required this.carrier,
    required this.fare,
    required this.rating,
    required this.deliveryDays,
    this.status,
  });

  final String id;
  final String carrier;
  final double fare;
  final double rating;
  final int deliveryDays;
  final String? status;

  ShipmentBidEntity copyWith({String? status}) => ShipmentBidEntity(
    id: id,
    carrier: carrier,
    fare: fare,
    rating: rating,
    deliveryDays: deliveryDays,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [id, carrier, fare, rating, deliveryDays, status];
}
