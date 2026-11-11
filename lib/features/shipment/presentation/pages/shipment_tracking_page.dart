import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/entities/shipment_entity.dart';
import '../bloc/query/shipment_query_bloc.dart';
import '../bloc/query/shipment_query_event.dart';
import '../bloc/query/shipment_query_state.dart';

class ShipmentTrackingPage extends StatefulWidget {
  const ShipmentTrackingPage({required this.shipmentId, super.key});

  final String shipmentId;

  @override
  State<ShipmentTrackingPage> createState() => _ShipmentTrackingPageState();
}

class _ShipmentTrackingPageState extends State<ShipmentTrackingPage> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _background => Theme.of(context).scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => di.sl<ShipmentQueryBloc>()..add(const LoadShipments()),
    child: Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: BlocBuilder<ShipmentQueryBloc, ShipmentQueryState>(
          builder: (context, state) {
            if (state.status == ShipmentQueryStatus.loading ||
                state.status == ShipmentQueryStatus.initial) {
              return LoadingSkeleton(
                layout: LoadingSkeletonLayout.tracking,
                backgroundColor: _background,
              );
            }
            if (state.status == ShipmentQueryStatus.failure) {
              return _messageState(
                'Could not load tracking details',
                onRetry: () => context.read<ShipmentQueryBloc>().add(
                  const LoadShipments(),
                ),
              );
            }
            final shipment = state.shipments
                .where((item) => item.id == widget.shipmentId)
                .firstOrNull;
            if (shipment == null) return _messageState('Shipment not found');
            return _trackingView(shipment);
          },
        ),
      ),
    ),
  );

  Widget _trackingView(ShipmentEntity shipment) {
    final stops = _stops(shipment);
    final status = _normalizedStatus(shipment.status);
    final progress = switch (status) {
      'delivered' || 'completed' => 1.0,
      'in transit' || 'active' || 'in progress' => 0.58,
      'scheduled' || 'confirmed' => 0.22,
      _ => 0.08,
    };
    final currentPlace = _currentPlace(shipment, stops, progress);
    final eta = _eta(shipment);
    final etaLabel = eta == null
        ? 'ETA pending'
        : 'ETA ${DateFormat('HH:mm').format(eta)}';
    final etaSubtext = eta == null
        ? 'Delivery estimate not provided'
        : '${DateFormat('EEEE · d MMM').format(eta)} · ${_remainingDistance(shipment, progress)} remaining';
    final carrier = _carrierName(shipment);

    return Column(
      children: [
        _topBar(shipment),
        Expanded(
          flex: 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _RouteMapPainter(
                  progress: progress,
                  delivered: status == 'delivered' || status == 'completed',
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
                child: const SizedBox.expand(),
              ),
              Positioned(
                left: 16,
                top: 14,
                child: _liveIndicator(status, shipment),
              ),
              Positioned(
                left: 16,
                bottom: 18,
                child: _mapLabel(
                  shipment.pickupLocation ?? 'Pickup',
                  _Place.start,
                ),
              ),
              Positioned(
                right: 16,
                top: 18,
                child: _mapLabel(
                  shipment.deliveryLocation ?? 'Delivery',
                  _Place.end,
                ),
              ),
              if (stops.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _StopMarkerPainter(stopCount: stops.length),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment(
                  -0.84 + 1.68 * progress,
                  0.76 - 1.48 * progress,
                ),
                child: IgnorePointer(
                  child: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: _orange,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33E84012), blurRadius: 10),
                      ],
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 10,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(17, 7, 17, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8DE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          etaLabel,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _statusPill(shipment.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    etaSubtext,
                    style: TextStyle(color: _muted, fontSize: 10.5),
                  ),
                  const SizedBox(height: 12),
                  _progressTrack(progress),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _routeCaption(shipment.pickupLocation ?? 'Pickup'),
                      _routeCaption(
                        '$currentPlace · ${(progress * 100).round()}%',
                      ),
                      _routeCaption(shipment.deliveryLocation ?? 'Delivery'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _carrierCard(shipment, carrier),
                  if (stops.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _stopsPanel(stops),
                  ],
                  const SizedBox(height: 9),
                  Center(
                    child: Text(
                      'Illustrative route · not live GPS tracking',
                      style: TextStyle(color: _muted, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(ShipmentEntity shipment) => Padding(
    padding: const EdgeInsets.fromLTRB(13, 7, 13, 8),
    child: Row(
      children: [
        _iconButton(Icons.arrow_back_rounded, 'Back', () => context.pop()),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E6EA)),
            ),
            child: Row(
              children: [
                Text(
                  shipment.reference ?? shipment.id,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '${shipment.pickupLocation ?? 'Pickup'} → ${shipment.deliveryLocation ?? 'Delivery'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _muted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _liveIndicator(String status, ShipmentEntity shipment) {
    final moving = status == 'in transit' || status == 'active';
    final lastUpdated = shipment.statusHistory.isNotEmpty
        ? shipment.statusHistory.last.at
        : shipment.updatedAt;
    final age = lastUpdated == null
        ? null
        : DateTime.now().difference(lastUpdated);
    final updateLabel = age == null || age.inMinutes < 1
        ? 'updated just now'
        : age.inHours < 1
        ? 'updated ${age.inMinutes} min ago'
        : 'updated ${age.inHours} hr ago';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF5EC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB4E7D5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            moving ? Icons.route_rounded : Icons.info_outline,
            size: 12,
            color: const Color(0xFF188565),
          ),
          const SizedBox(width: 5),
          Text(
            moving ? 'Route progress · $updateLabel' : 'Route preview',
            style: TextStyle(
              color: Color(0xFF188565),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapLabel(String text, _Place place) => Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: place == _Place.end ? _orange : _ink,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _progressTrack(double progress) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      children: [
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0, 1),
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _routeCaption(String text) => Flexible(
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _muted, fontSize: 9),
    ),
  );

  Widget _statusPill(String status) {
    final normalized = _normalizedStatus(status);
    final moving = normalized == 'in transit' || normalized == 'active';
    final color = moving ? _orange : const Color(0xFF2878C8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            moving ? Icons.local_shipping_rounded : Icons.schedule_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _displayStatus(status),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carrierCard(ShipmentEntity shipment, String carrier) {
    final driver = shipment.extraData['driverName']?.toString();
    final registration = shipment.extraData['vehicleRegistration']?.toString();
    final phone = shipment.extraData['driverPhone']?.toString();
    final initials = carrier
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE6E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFFFFF0E9),
            child: Text(
              initials.isEmpty ? 'L' : initials,
              style: TextStyle(
                color: _orange,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver ?? carrier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  carrier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 9.5),
                ),
                Text(
                  registration ??
                      shipment.vehicleType ??
                      'Vehicle details not provided',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 8.5),
                ),
              ],
            ),
          ),
          if (phone != null && phone.isNotEmpty)
            IconButton(
              tooltip: 'Call carrier',
              onPressed: () => _showContactNotice(),
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.call_outlined, color: _orange, size: 18),
            ),
          IconButton(
            tooltip: 'Message carrier',
            onPressed: _showContactNotice,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.chat_bubble_outline_rounded,
              color: _orange,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopsPanel(List<_TrackingStop> stops) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Route stops',
        style: TextStyle(
          color: _ink,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      for (final stop in stops)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Icon(
                stop.type == 'pickup'
                    ? Icons.add_location_alt_outlined
                    : Icons.flag_outlined,
                color: _orange,
                size: 14,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  stop.location,
                  style: TextStyle(color: _ink, fontSize: 9.5),
                ),
              ),
              if (stop.weightTonnes > 0)
                Text(
                  '${stop.weightTonnes} t',
                  style: TextStyle(color: _muted, fontSize: 9),
                ),
            ],
          ),
        ),
    ],
  );

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onPressed) =>
      SizedBox(
        width: 38,
        height: 38,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon, size: 19, color: _ink),
        ),
      );

  Widget _messageState(String message, {VoidCallback? onRetry}) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, style: TextStyle(color: _ink)),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text('Retry')),
      ],
    ),
  );

  List<_TrackingStop> _stops(ShipmentEntity shipment) {
    final rawStops = shipment.extraData['intermediateStops'];
    if (rawStops is! List) return const [];
    return rawStops.whereType<Map>().map((stop) {
      return _TrackingStop(
        location: stop['location']?.toString() ?? 'Stop',
        type: stop['type']?.toString() ?? 'drop',
        weightTonnes: (stop['weightTonnes'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  String _currentPlace(
    ShipmentEntity shipment,
    List<_TrackingStop> stops,
    double progress,
  ) {
    if (shipment.statusHistory.isNotEmpty) {
      final location = shipment.statusHistory.last.location;
      if (location != null && location.isNotEmpty) return location;
    }
    if (stops.isNotEmpty && progress > 0.35 && progress < 0.85) {
      return stops.first.location;
    }
    return progress >= 1
        ? shipment.deliveryLocation ?? 'Delivered'
        : 'En route';
  }

  DateTime? _eta(ShipmentEntity shipment) {
    final deliveryAt = shipment.extraData['deliveryAt'];
    if (deliveryAt is DateTime) return deliveryAt;
    if (deliveryAt != null) {
      try {
        return (deliveryAt as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.tryParse(deliveryAt.toString());
      }
    }
    final acceptedDeliveryDays = shipment.acceptedBid?.deliveryDays;
    if (shipment.pickupAt != null && acceptedDeliveryDays != null) {
      return shipment.pickupAt!.add(Duration(days: acceptedDeliveryDays));
    }
    return null;
  }

  String _carrierName(ShipmentEntity shipment) =>
      shipment.assignedCarrier ??
      shipment.acceptedBid?.carrier ??
      shipment.extraData['carrierName']?.toString() ??
      'Carrier not assigned';

  String _remainingDistance(ShipmentEntity shipment, double progress) {
    final distance = shipment.extraData['routeDistanceKm'];
    if (distance is num) return '${(distance * (1 - progress)).round()} km';
    return 'Route estimate';
  }

  String _normalizedStatus(String status) =>
      status.toLowerCase().replaceAll('_', ' ');

  String _displayStatus(String status) {
    final normalized = _normalizedStatus(status);
    if (normalized == 'active') return 'In transit';
    return normalized.isEmpty
        ? 'Pending'
        : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  void _showContactNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Direct carrier contact is not available in this demo.'),
      ),
    );
  }
}

class _TrackingStop {
  const _TrackingStop({
    required this.location,
    required this.type,
    required this.weightTonnes,
  });
  final String location;
  final String type;
  final double weightTonnes;
}

enum _Place { start, end }

class _RouteMapPainter extends CustomPainter {
  const _RouteMapPainter({
    required this.progress,
    required this.delivered,
    required this.isDark,
  });
  final double progress;
  final bool delivered;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..color = isDark ? const Color(0xFF20252B) : const Color(0xFFE8EAF0),
    );

    final grid = Paint()
      ..color = isDark ? const Color(0xFF2C333B) : const Color(0xFFDDE0E7)
      ..strokeWidth = 0.7;
    for (var x = 0.0; x < size.width; x += 27) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 27) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    final route = _routePath(size);
    canvas.drawPath(route, roadPaint);
    final secondary = Path()
      ..moveTo(size.width * 0.22, size.height)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.72,
        size.width * 0.4,
        size.height * 0.52,
        size.width * 0.58,
        size.height * 0.08,
      );
    canvas.drawPath(secondary, roadPaint..strokeWidth = 10);

    final routeBackground = Paint()
      ..color = const Color(0xFFFFC99D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(route, routeBackground);
    final routeProgressPaint = Paint()
      ..color = const Color(0xFFFF6900)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final metric = route.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress.clamp(0, 1)),
      routeProgressPaint,
    );

    final start = Offset(size.width * 0.1, size.height * 0.88);
    final end = Offset(size.width * 0.92, size.height * 0.14);
    _dot(canvas, start, const Color(0xFF25252B), 6);
    _dot(canvas, end, const Color(0xFFFF6900), 8);
    if (delivered) _dot(canvas, end, const Color(0xFF179879), 8);
  }

  Path _routePath(Size size) => Path()
    ..moveTo(size.width * 0.08, size.height * 0.9)
    ..cubicTo(
      size.width * 0.34,
      size.height * 0.79,
      size.width * 0.4,
      size.height * 0.58,
      size.width * 0.56,
      size.height * 0.43,
    )
    ..cubicTo(
      size.width * 0.72,
      size.height * 0.28,
      size.width * 0.76,
      size.height * 0.2,
      size.width * 0.94,
      size.height * 0.12,
    );

  void _dot(Canvas canvas, Offset point, Color color, double radius) {
    canvas.drawCircle(
      point,
      radius + 5,
      Paint()..color = color.withValues(alpha: 0.14),
    );
    canvas.drawCircle(point, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RouteMapPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      delivered != oldDelegate.delivered ||
      isDark != oldDelegate.isDark;
}

class _StopMarkerPainter extends CustomPainter {
  const _StopMarkerPainter({required this.stopCount});
  final int stopCount;
  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < stopCount && index < 4; index++) {
      final t = (index + 1) / (math.min(stopCount, 4) + 1);
      final point = Offset(
        size.width * (0.1 + 0.82 * t),
        size.height * (0.88 - 0.74 * t),
      );
      canvas.drawCircle(point, 6, Paint()..color = Colors.white);
      canvas.drawCircle(point, 4, Paint()..color = const Color(0xFF7C8796));
    }
  }

  @override
  bool shouldRepaint(covariant _StopMarkerPainter oldDelegate) =>
      stopCount != oldDelegate.stopCount;
}
