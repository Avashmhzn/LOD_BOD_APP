import 'package:equatable/equatable.dart';

class ShipmentStatusEvent extends Equatable {
  const ShipmentStatusEvent({
    required this.status,
    required this.at,
    this.note,
    this.location,
  });

  final String status;
  final DateTime? at;
  final String? note;
  final String? location;

  @override
  List<Object?> get props => [status, at, note, location];
}
