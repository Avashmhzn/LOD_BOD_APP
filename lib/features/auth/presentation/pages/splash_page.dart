import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/core/widgets/brand_splash.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_state.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _minimumSplashDuration = Duration(milliseconds: 1200);
  static const _progressFinishDuration = Duration(milliseconds: 180);
  late final DateTime _splashStartedAt;
  bool _navigationScheduled = false;
  bool _progressComplete = false;

  @override
  void initState() {
    super.initState();
    _splashStartedAt = DateTime.now();
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  Future<void> _navigateAfterSplash(String route) async {
    if (_navigationScheduled) return;
    _navigationScheduled = true;

    final elapsed = DateTime.now().difference(_splashStartedAt);
    final remaining = _minimumSplashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;
    setState(() => _progressComplete = true);
    await Future<void>.delayed(_progressFinishDuration);
    if (mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _navigateAfterSplash(Routes.dashboard);
        } else if (state is Unauthenticated) {
          _navigateAfterSplash(Routes.login);
        }
      },
      child: BrandSplash(
        statusText: 'Checking your session...',
        progressDuration: _minimumSplashDuration,
        progressComplete: _progressComplete,
      ),
    );
  }
}
