
import 'package:flutter/material.dart';

class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => DashboardSkeletonState();
}

class DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.45,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({double? width, required double height, double radius = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FadeTransition(
          opacity: _opacity,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              // header
              Row(
                children: [
                  _box(width: 40, height: 40, radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _box(width: 90, height: 9, radius: 5),
                        const SizedBox(height: 7),
                        _box(width: 150, height: 12, radius: 6),
                      ],
                    ),
                  ),
                  _box(width: 42, height: 42, radius: 13),
                ],
              ),
              const SizedBox(height: 18),
              // banner
              _box(height: 92, radius: 16),
              const SizedBox(height: 14),
              // metrics
              Row(
                children: [
                  Expanded(child: _box(height: 94)),
                  const SizedBox(width: 10),
                  Expanded(child: _box(height: 94)),
                  const SizedBox(width: 10),
                  Expanded(child: _box(height: 94)),
                ],
              ),
              const SizedBox(height: 24),
              _box(width: 120, height: 11, radius: 6),
              const SizedBox(height: 10),
              _box(height: 62),
              const SizedBox(height: 24),
              _box(width: 130, height: 11, radius: 6),
              const SizedBox(height: 10),
              _box(height: 130),
            ],
          ),
        ),
      ],
    );
  }
}
