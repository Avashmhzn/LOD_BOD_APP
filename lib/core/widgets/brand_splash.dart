import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrandSplash extends StatefulWidget {
  const BrandSplash({
    super.key,
    required this.statusText,
    this.progressDuration,
    this.progressComplete = false,
  });

  final String statusText;
  final Duration? progressDuration;
  final bool progressComplete;

  @override
  State<BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<BrandSplash>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _progressController;
  late final Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 1, end: 1.035).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutSine,
      ),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: widget.progressDuration ?? const Duration(milliseconds: 1500),
    );
    if (widget.progressDuration == null) {
      _progressController.repeat();
    } else {
      _progressController.animateTo(
        0.9,
        duration: widget.progressDuration,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant BrandSplash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progressComplete && !oldWidget.progressComplete) {
      _progressController.animateTo(
        1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _breathingAnimation,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE63D13),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE63D13)
                                  .withValues(alpha: 0.2),
                              blurRadius: 28,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'LOD',
                              style: TextStyle(
                                color: isDark
                                    ? theme.colorScheme.onSurface
                                    : Color(0xFF171717),
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                                height: 1,
                              ),
                            ),
                            Text(
                              'BOD',
                              style: TextStyle(
                                color: Color(0xFFE63D13),
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.6,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'S H I P P E R',
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 32,
                right: 32,
                bottom: 24,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 5,
                                  child: Stack(
                                    children: [
                                      const ColoredBox(
                                        color: Color(0xFFE5E5E5),
                                        child: SizedBox.expand(),
                                      ),
                                      AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (context, child) {
                                          final progress =
                                              widget.progressDuration == null
                                              ? 0.28 +
                                                    (_progressController.value *
                                                        0.45)
                                              : _progressController.value;
                                          return FractionallySizedBox(
                                            widthFactor: progress,
                                            child: child,
                                          );
                                        },
                                        child: const ColoredBox(
                                          color: Color(0xFFE63D13),
                                          child: SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.statusText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF858585),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'v1.0.0',
                              style: TextStyle(
                                color: Color(0xFF858585),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
