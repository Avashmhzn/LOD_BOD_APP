import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/core/utils/validators.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:lodbod_app/features/auth/presentation/widget/field_widget.dart';
import 'package:lodbod_app/features/auth/presentation/widget/header_widget.dart';
import 'package:lodbod_app/features/auth/presentation/widget/term_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _brand = Color(0xFFE63B0B);
  Color get _background => Theme.of(context).scaffoldBackgroundColor;
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _border => Theme.of(context).colorScheme.outlineVariant;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  final String _role = 'shipper';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Full name required';
    if (name.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateOptionalEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required for account creation';
    if (!Validators.isValidEmail(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validateRegistrationPassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'\d'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please agree to the terms to continue'),
          ),
        );
      return;
    }

    context.read<AuthBloc>().add(
      SignUpEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim().replaceAll(
          RegExp(r'[\s\-()]'),
          '',
        ),
        displayName: _nameController.text.trim(),
        companyName: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        role: _role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is Authenticated) {
              context.go(Routes.dashboard);
            } else if (state is Unauthenticated) {
              context.go(Routes.login);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RegisterHeaderWidget(
                            inkColor: _ink,
                            borderColor: _border,
                            onBack: () => Navigator.of(context).maybePop(),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 4,
                              backgroundColor: Color(0xFFE0E0E5),
                              valueColor: AlwaysStoppedAnimation(_brand),
                            ),
                          ),
                          const SizedBox(height: 12),
                          RegisterFieldWidget(
                            label: 'Full name',
                            controller: _nameController,
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            validator: _validateName,
                            textInputAction: TextInputAction.next,
                            brandColor: _brand,
                            inkColor: _ink,
                            mutedColor: _muted,
                            borderColor: _border,
                          ),
                          const SizedBox(height: 10),
                          RegisterFieldWidget(
                            label: 'Phone number',
                            controller: _phoneController,
                            hint: '+977 98XXXXXXXX',
                            icon: Icons.call_outlined,
                            keyboardType: TextInputType.phone,
                            validator: Validators.validatePhone,
                            textInputAction: TextInputAction.next,
                            brandColor: _brand,
                            inkColor: _ink,
                            mutedColor: _muted,
                            borderColor: _border,
                          ),
                          const SizedBox(height: 10),
                          RegisterFieldWidget(
                            label: 'Email',
                            controller: _emailController,
                            hint: 'you@company.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateOptionalEmail,
                            textInputAction: TextInputAction.next,
                            brandColor: _brand,
                            inkColor: _ink,
                            mutedColor: _muted,
                            borderColor: _border,
                          ),
                          const SizedBox(height: 10),
                          RegisterFieldWidget(
                            label: 'Company name (optional)',
                            requiredField: false,
                            controller: _companyController,
                            hint: 'Your company name',
                            icon: Icons.apartment_rounded,
                            textInputAction: TextInputAction.next,
                            brandColor: _brand,
                            inkColor: _ink,
                            mutedColor: _muted,
                            borderColor: _border,
                          ),
                          const SizedBox(height: 10),
                          RegisterFieldWidget(
                            label: 'Password',
                            controller: _passwordController,
                            hint: 'Min. 8 characters',
                            icon: Icons.lock_outline_rounded,
                            validator: _validateRegistrationPassword,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleRegister(),
                            brandColor: _brand,
                            inkColor: _ink,
                            mutedColor: _muted,
                            borderColor: _border,
                            suffix: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _muted,
                                size: 19,
                              ),
                            ),
                            helperText: 'Use 8+ characters with a number.',
                          ),
                          const SizedBox(height: 8),
                          RegisterTermsWidget(
                            agreed: _agreedToTerms,
                            brandColor: _brand,
                            mutedColor: _muted,
                            borderColor: _border,
                            onChanged: (value) =>
                                setState(() => _agreedToTerms = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: FilledButton.styleFrom(
                        backgroundColor: _brand,
                        disabledBackgroundColor: _brand.withValues(alpha: 0.65),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: _brand.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
