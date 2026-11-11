import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/theme/app_colors.dart';
import 'package:lodbod_app/core/theme/app_text_styles.dart';
import 'package:lodbod_app/core/widgets/custom_button.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';


class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _remainingSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    if (_canResend) {
      context.read<AuthBloc>().add(ResendOtpEvent(email: widget.email));
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is Authenticated) {
              context.go(Routes.dashboard);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    Icons.email_outlined,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Verification Link Sent',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'We sent a verification link to\n${widget.email}.\nPlease click the link in your email, then tap the button below to continue.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  CustomButton(
                    text: 'I have verified my email',
                    onPressed: isLoading ? null : () {
                       context.read<AuthBloc>().add(CheckAuthStatusEvent());
                    },
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Didn\'t receive code? ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _canResend ? _handleResend : null,
                        child: Text(
                          _canResend
                              ? 'Resend'
                              : 'Resend in ${_remainingSeconds}s',
                          style: TextStyle(
                            color: _canResend
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
