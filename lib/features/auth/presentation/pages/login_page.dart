import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/core/utils/validators.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_state.dart';

import '../bloc/auth_bloc.dart';
import '../widget/create_account_button_widget.dart';
import '../widget/divider_widget.dart';
import '../widget/email_field_widget.dart';
import '../widget/footer_widget.dart';
import '../widget/login_button_widget.dart';
import '../widget/logo_widget.dart';
import '../widget/method_toggle_widget.dart';
import '../widget/option_widget.dart';
import '../widget/password_field_widget.dart';
import '../widget/phone_field_widget.dart';

enum LoginMethod { phone, email }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _brand = Color(0xFFE0400A);
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _border => Theme.of(context).colorScheme.outlineVariant;

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  LoginMethod _method = LoginMethod.phone;
  bool _obscurePassword = true;
  bool _keepSignedIn = true;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () {};
    _privacyTap = TapGestureRecognizer()..onTap = () {};
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
    if (digits.isEmpty) return 'Phone number required';
    if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email required';
    if (!Validators.isValidEmail(input)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final String identifier;
    if (_method == LoginMethod.phone) {
      final digits = _phoneController.text.replaceAll(RegExp(r'[\s\-()]'), '');
      identifier = '+977$digits';
    } else {
      identifier = _emailController.text.trim();
    }

    context.read<AuthBloc>().add(
      SignInEvent(
        identifier: identifier,
        password: _passwordController.text,
        isPhone: _method == LoginMethod.phone,
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
        title: Text('Login successful', textAlign: TextAlign.center),
        content: Text(
          'Welcome back! You have signed in successfully.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _brand),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.go(Routes.dashboard);
  }

  Future<void> _showLoginErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.error_outline_rounded, color: _brand, size: 48),
        title: Text('Login failed', textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _brand),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              _showLoginErrorDialog(state.message);
            } else if (state is Authenticated) {
              _showSuccessDialog();
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LoginLogoWidget(),
                          const SizedBox(height: 28),
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log in to manage your shipments.',
                            style: TextStyle(fontSize: 14, color: _muted),
                          ),
                          const SizedBox(height: 24),
                          LoginMethodToggleWidget(
                            usePhone: _method == LoginMethod.phone,
                            onChanged: (usePhone) {
                              final nextMethod = usePhone
                                  ? LoginMethod.phone
                                  : LoginMethod.email;
                              if (_method == nextMethod) return;
                              setState(() => _method = nextMethod);
                              _formKey.currentState?.reset();
                            },
                            activeColor: _brand,
                            inkColor: _ink,
                            borderColor: _border,
                          ),
                          const SizedBox(height: 18),

                          ClipRect(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final incomingFrom =
                                    _method == LoginMethod.email
                                    ? const Offset(1, 0)
                                    : const Offset(-1, 0);
                                final slide =
                                    Tween<Offset>(
                                      begin: incomingFrom,
                                      end: Offset.zero,
                                    ).chain(
                                      CurveTween(curve: Curves.easeInOutCubic),
                                    );

                                return SlideTransition(
                                  position: animation.drive(slide),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(_method),
                                child: _method == LoginMethod.phone
                                    ? PhoneFieldWidget(
                                        controller: _phoneController,
                                        textColor: _ink,
                                        decoration: _decoration(
                                          hint: '98XXXXXXXX',
                                          icon: Icons.phone_outlined,
                                          prefixText: '+977  ',
                                        ),
                                        validator: _validatePhone,
                                      )
                                    : EmailFieldWidget(
                                        controller: _emailController,
                                        textColor: _ink,
                                        decoration: _decoration(
                                          hint: 'you@example.com',
                                          icon: Icons.mail_outline_rounded,
                                        ),
                                        validator: _validateEmail,
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          PasswordFieldWidget(
                            controller: _passwordController,
                            textColor: _ink,
                            mutedColor: _muted,
                            decoration: _decoration(
                              hint: 'Enter your password',
                              icon: Icons.lock_outline_rounded,
                            ),
                            validator: _validatePassword,
                            obscurePassword: _obscurePassword,
                            onToggleVisibility: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            onSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 14),
                          LoginOptionsWidget(
                            isLoading: isLoading,
                            keepSignedIn: _keepSignedIn,
                            onKeepSignedInChanged: (value) =>
                                setState(() => _keepSignedIn = value),
                            onForgotPassword: () =>
                                context.push(Routes.forgotPassword),
                            activeColor: _brand,
                            mutedColor: _muted,
                            borderColor: _border,
                          ),
                          const SizedBox(height: 24),
                          LoginButtonWidget(
                            isLoading: isLoading,
                            color: _brand,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 18),
                          LoginDividerWidget(
                            borderColor: _border,
                            mutedColor: _muted,
                          ),
                          const SizedBox(height: 18),
                          CreateAccountButtonWidget(
                            isLoading: isLoading,
                            surfaceColor: Theme.of(context).colorScheme.surface,
                            textColor: _ink,
                            borderColor: _border,
                            onPressed: () => context.push(Routes.register),
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          LoginFooterWidget(
                            mutedColor: _muted,
                            linkColor: _brand,
                            termsTap: _termsTap,
                            privacyTap: _privacyTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  OutlineInputBorder _outline(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFFA0A0AA), fontSize: 15),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: Icon(icon, size: 20),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.focused) ? _brand : _muted,
      ),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      suffixIcon: suffix,
      border: _outline(_border),
      enabledBorder: _outline(_border),
      focusedBorder: _outline(_brand, width: 1.5),
      errorBorder: _outline(Colors.red.shade400),
      focusedErrorBorder: _outline(Colors.red.shade400, width: 1.5),
    );
  }
}
