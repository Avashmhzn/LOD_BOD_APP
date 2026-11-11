import 'package:flutter/material.dart';
import 'package:lodbod_app/core/theme/app_colors.dart';

enum LoadingSkeletonLayout { account, list, analytics, detail, tracking }

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    this.layout = LoadingSkeletonLayout.list,
    this.backgroundColor,
    super.key,
  });

  final LoadingSkeletonLayout layout;
  final Color? backgroundColor;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
    child: _layout(),
  );

  Widget _layout() {
    final children = switch (widget.layout) {
      LoadingSkeletonLayout.account => _accountLayout(),
      LoadingSkeletonLayout.list => _listLayout(),
      LoadingSkeletonLayout.analytics => _analyticsLayout(),
      LoadingSkeletonLayout.detail => _detailLayout(),
      LoadingSkeletonLayout.tracking => _trackingLayout(),
    };

    return ColoredBox(
      color:
          widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: children,
      ),
    );
  }

  List<Widget> _accountLayout() => [
    _block(double.infinity, 54, radius: 14),
    const SizedBox(height: 18),
    for (var section = 0; section < 3; section++) ...[
      _block(110, 10),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? const []
              : AppColors.cardShadow,
        ),
        child: Column(
          children: [
            for (var row = 0; row < (section == 0 ? 2 : 3); row++) ...[
              SizedBox(
                height: 42,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _block(16, 16, radius: 4),
                      const SizedBox(width: 10),
                      Expanded(child: _block(120, 11)),
                      _block(32, 10),
                    ],
                  ),
                ),
              ),
              if (row < (section == 0 ? 1 : 2))
                Divider(
                  height: 1,
                  indent: 38,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
    ],
    Row(
      children: [
        Expanded(child: _block(double.infinity, 44, radius: 10)),
        const SizedBox(width: 10),
        Expanded(child: _block(double.infinity, 44, radius: 10)),
      ],
    ),
  ];

  List<Widget> _listLayout() => [
    _block(140, 22),
    const SizedBox(height: 16),
    _block(double.infinity, 46, radius: 12),
    const SizedBox(height: 14),
    for (var index = 0; index < 4; index++) ...[
      _block(double.infinity, 132, radius: 13),
      const SizedBox(height: 10),
    ],
  ];

  List<Widget> _analyticsLayout() => [
    Row(
      children: [
        Expanded(child: _block(double.infinity, 88, radius: 14)),
        const SizedBox(width: 10),
        Expanded(child: _block(double.infinity, 88, radius: 14)),
      ],
    ),
    const SizedBox(height: 18),
    _block(double.infinity, 230, radius: 14),
    const SizedBox(height: 12),
    _block(double.infinity, 76, radius: 14),
  ];

  List<Widget> _detailLayout() => [
    _block(double.infinity, 150, radius: 14),
    const SizedBox(height: 12),
    _block(double.infinity, 44, radius: 12),
    const SizedBox(height: 12),
    _block(double.infinity, 170, radius: 14),
    const SizedBox(height: 12),
    _block(double.infinity, 120, radius: 14),
  ];

  List<Widget> _trackingLayout() => [
    _block(double.infinity, 58, radius: 14),
    const SizedBox(height: 12),
    _block(double.infinity, 300, radius: 14),
    const SizedBox(height: 12),
    _block(double.infinity, 90, radius: 14),
  ];

  Widget _block(double width, double height, {double radius = 8}) => Container(
    width: width.isInfinite ? null : width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
