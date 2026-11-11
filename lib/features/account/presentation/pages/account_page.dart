import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/core/di/injection_container.dart' as di;
import 'package:lodbod_app/core/theme/app_settings.dart';
import 'package:lodbod_app/core/widgets/bottom_navigation.dart';
import 'package:lodbod_app/core/widgets/loading_skeleton.dart';
import 'package:lodbod_app/features/account/presentation/widget/choose_tile_widget.dart';
import 'package:lodbod_app/features/account/presentation/widget/group_widget.dart';
import 'package:lodbod_app/features/account/presentation/widget/profile_card_widget.dart';
import 'package:lodbod_app/features/account/presentation/widget/row_widget.dart';
import 'package:lodbod_app/features/account/presentation/widget/section_label_widget.dart';
import 'package:lodbod_app/features/account/presentation/widget/themed_alert_widget.dart';
import 'package:lodbod_app/l10n/app_localizations.dart';

import '../bloc/account_profile_bloc.dart';
import '../bloc/account_profile_event.dart';
import '../bloc/account_profile_state.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const _accent = Color(0xFFE84012);

  bool _isBusy = false;
  bool _notificationsEnabled = true;

  Future<void> chooseAppearance(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.appearance),
        children: [
          choiceTile<ThemeMode>(
            dialogContext,
            l.system,
            ThemeMode.system,
            selected: appSettings.themeMode == ThemeMode.system,
          ),
          choiceTile<ThemeMode>(
            dialogContext,
            l.light,
            ThemeMode.light,
            selected: appSettings.themeMode == ThemeMode.light,
          ),
          choiceTile<ThemeMode>(
            dialogContext,
            l.dark,
            ThemeMode.dark,
            selected: appSettings.themeMode == ThemeMode.dark,
          ),
        ],
      ),
    );
    if (selected != null) await appSettings.setThemeMode(selected);
  }

  Future<void> chooseLanguage(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.language),
        children: [
          choiceTile<String>(
            dialogContext,
            l.systemDefault,
            'system',
            selected: appSettings.locale == null,
          ),
          choiceTile<String>(
            dialogContext,
            l.english,
            'en',
            selected: appSettings.locale?.languageCode == 'en',
          ),
          choiceTile<String>(
            dialogContext,
            l.nepali,
            'ne',
            selected: appSettings.locale?.languageCode == 'ne',
          ),
          choiceTile<String>(
            dialogContext,
            l.hindi,
            'hi',
            selected: appSettings.locale?.languageCode == 'hi',
          ),
        ],
      ),
    );
    if (selected != null) {
      await appSettings.setLocale(
        selected == 'system' ? null : Locale(selected),
      );
    }
  }

  Future<void> confirmDeleteAccount(
    BuildContext context, {
    required AccountProfileBloc accountBloc,
  }) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteAccountDialog(localizations: l),
    );
    if (confirmed != true || !context.mounted) return;
    accountBloc.add(const DeleteAccount());
  }

  Future<void> editProfile(
    BuildContext context, {
    required String name,
    required String company,
    required AccountProfileBloc accountBloc,
  }) async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<({String name, String company})>(
      context: context,
      builder: (_) =>
          _EditProfileDialog(name: name, company: company, localizations: l),
    );

    if (result != null && context.mounted) {
      accountBloc.add(
        SaveAccountProfile(
          displayName: result.name,
          companyName: result.company,
        ),
      );
    }
  }

  Future<void> resetPassword(
    BuildContext context,
    String email, {
    required AccountProfileBloc accountBloc,
  }) async {
    final l = AppLocalizations.of(context)!;
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => themedAlert(
        dialogContext,
        AlertDialog(
          title: Text(l.resetPassword),
          content: Text(l.resetPasswordExplanation(email)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.sendLink),
            ),
          ],
        ),
      ),
    );
    if (shouldSend != true || !context.mounted) return;
    accountBloc.add(SendAccountPasswordReset(email));
  }

  Future<void> confirmSignOut(
    BuildContext context, {
    required AccountProfileBloc accountBloc,
  }) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => themedAlert(
        dialogContext,
        AlertDialog(
          title: Text(l.signOutQuestion),
          content: Text(l.signBackInAnytime),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l.signOut),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;
    accountBloc.add(const SignOutAccount());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = di.sl<FirebaseAuth>().currentUser;
    final l = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) =>
          di.sl<AccountProfileBloc>()..add(const LoadAccountProfile()),
      child: Builder(
        builder: (blocContext) =>
            BlocListener<AccountProfileBloc, AccountProfileState>(
              listener: (context, state) {
                if (state.status == AccountProfileStatus.actionLoading) {
                  if (!_isBusy) setState(() => _isBusy = true);
                  return;
                }
                if (state.status != AccountProfileStatus.actionSuccess &&
                    state.status != AccountProfileStatus.actionFailure) {
                  return;
                }
                if (_isBusy) setState(() => _isBusy = false);

                if (state.status == AccountProfileStatus.actionSuccess) {
                  switch (state.action) {
                    case AccountProfileAction.save:
                      _showMessage(l.profileUpdated);
                      blocContext.read<AccountProfileBloc>().add(
                        const LoadAccountProfile(),
                      );
                    case AccountProfileAction.passwordReset:
                      _showMessage(l.passwordResetLinkSent(state.email ?? ''));
                    case AccountProfileAction.signOut:
                    case AccountProfileAction.delete:
                      blocContext.go(Routes.login);
                    case null:
                      break;
                  }
                } else {
                  final error = state.message ?? '';
                  final message = switch (state.action) {
                    AccountProfileAction.save => l.couldNotUpdateProfile(error),
                    AccountProfileAction.passwordReset =>
                      l.couldNotSendResetLink(error),
                    AccountProfileAction.signOut => l.couldNotSignOut(error),
                    AccountProfileAction.delete => l.couldNotDeleteAccount(
                      error,
                    ),
                    null => error,
                  };
                  _showMessage(message);
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(l.account),
                  actions: [
                    IconButton(
                      tooltip: l.notifications,
                      onPressed: () => _showMessage(l.notificationsUnavailable),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                body: BlocBuilder<AccountProfileBloc, AccountProfileState>(
                  builder: (context, state) {
                    if (state.status == AccountProfileStatus.initial ||
                        state.status == AccountProfileStatus.loading) {
                      return LoadingSkeleton(
                        layout: LoadingSkeletonLayout.account,
                        backgroundColor: theme.scaffoldBackgroundColor,
                      );
                    }

                    final profile = state.profile;
                    final name =
                        (profile['displayName'] as String?)
                                ?.trim()
                                .isNotEmpty ==
                            true
                        ? (profile['displayName'] as String).trim()
                        : user?.displayName?.trim().isNotEmpty == true
                        ? user!.displayName!.trim()
                        : user?.email?.split('@').first ?? l.shipper;
                    final company = profile['companyName'] as String? ?? '';
                    final email = user?.email ?? '';

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      children: [
                        if (state.status == AccountProfileStatus.failure)
                          MaterialBanner(
                            content: const Text(
                              'Could not load account details.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context
                                    .read<AccountProfileBloc>()
                                    .add(const LoadAccountProfile()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        profileCard(
                          context,
                          name: name,
                          company: company,
                          roleLabel: roleLabel(
                            context,
                            profile['role'] as String? ?? 'shipper',
                          ),
                          email: email,
                          photoUrl: profile['photoUrl'] as String?,
                          onTap: () => editProfile(
                            context,
                            name: name,
                            company: company,
                            accountBloc: blocContext.read<AccountProfileBloc>(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        sectionLabel(context, l.accountSection),
                        group(context, [
                          row(
                            context,
                            icon: Icons.person_outline_rounded,
                            title: l.profileCompany,
                            onTap: () => editProfile(
                              context,
                              name: name,
                              company: company,
                              accountBloc: blocContext
                                  .read<AccountProfileBloc>(),
                            ),
                          ),
                          row(
                            context,
                            icon: Icons.groups_rounded,
                            title: l.teamAccess,
                            onTap: () => _showMessage(l.teamAccessUnavailable),
                          ),
                          row(
                            context,
                            icon: Icons.favorite_border_rounded,
                            title: l.favoriteCarriers,
                            onTap: () =>
                                _showMessage(l.favoriteCarriersUnavailable),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        sectionLabel(context, l.preferences),
                        group(context, [
                          row(
                            context,
                            icon: Icons.translate_rounded,
                            title: l.language,
                            value: switch (appSettings.locale?.languageCode) {
                              'ne' => 'Nepali',
                              'hi' => 'Hindi',
                              'en' => 'English',
                              _ => 'System',
                            },
                            onTap: () => chooseLanguage(context),
                          ),
                          row(
                            context,
                            icon: Icons.contrast_rounded,
                            title: l.appearance,
                            value: themeLabel(context, appSettings.themeMode),
                            onTap: () => chooseAppearance(context),
                          ),
                          row(
                            context,
                            icon: Icons.notifications_none_rounded,
                            title: l.notifications,
                            switchValue: _notificationsEnabled,
                            onSwitchChanged: (value) =>
                                setState(() => _notificationsEnabled = value),
                          ),
                          row(
                            context,
                            icon: Icons.link_rounded,
                            title: l.integrations,
                            onTap: () =>
                                _showMessage(l.integrationsUnavailable),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        sectionLabel(context, l.supportFeedback),
                        group(context, [
                          row(
                            context,
                            icon: Icons.help_outline_rounded,
                            title: l.helpCenter,
                            onTap: () => _showMessage(l.helpCenterUnavailable),
                          ),
                          row(
                            context,
                            icon: Icons.lightbulb_outline_rounded,
                            title: l.requestFeature,
                            onTap: () =>
                                _showMessage(l.featureRequestsUnavailable),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        sectionLabel(context, l.legalSecurity),
                        group(context, [
                          row(
                            context,
                            icon: Icons.verified_user_outlined,
                            title: l.securityPassword,
                            onTap: email.isEmpty
                                ? null
                                : () => resetPassword(
                                    context,
                                    email,
                                    accountBloc: blocContext
                                        .read<AccountProfileBloc>(),
                                  ),
                          ),
                          row(
                            context,
                            icon: Icons.description_outlined,
                            title: l.termsPrivacy,
                            onTap: () => _showMessage(l.legalUnavailable),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isBusy
                                    ? null
                                    : () => confirmSignOut(
                                        context,
                                        accountBloc: blocContext
                                            .read<AccountProfileBloc>(),
                                      ),
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 17,
                                ),
                                label: Text(l.signOut),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _accent,
                                  side: BorderSide(
                                    color: colors.outlineVariant,
                                  ),
                                  minimumSize: const Size.fromHeight(44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isBusy
                                    ? null
                                    : () => confirmDeleteAccount(
                                        context,
                                        accountBloc: blocContext
                                            .read<AccountProfileBloc>(),
                                      ),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 17,
                                  color: colors.error,
                                ),
                                label: Text(
                                  l.deleteAccount,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colors.error),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: colors.outlineVariant,
                                  ),
                                  minimumSize: const Size.fromHeight(44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
              ),
            ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String roleLabel(BuildContext context, String role) {
    final l = AppLocalizations.of(context)!;
    return switch (role.toLowerCase()) {
      'admin' => l.adminRole,
      'carrier' => l.carrierRole,
      _ => l.shipper,
    };
  }

  String themeLabel(BuildContext context, ThemeMode mode) {
    final l = AppLocalizations.of(context)!;
    return switch (mode) {
      ThemeMode.light => l.light,
      ThemeMode.dark => l.dark,
      ThemeMode.system => l.system,
    };
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.name,
    required this.company,
    required this.localizations,
  });

  final String name;
  final String company;
  final AppLocalizations localizations;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.name,
  );
  late final TextEditingController _companyController = TextEditingController(
    text: widget.company,
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.localizations;
    return themedAlert(
      context,
      AlertDialog(
        scrollable: true,
        title: Text(l.profileCompany),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l.fullName),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? l.enterName : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l.companyName),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(context, (
                name: _nameController.text.trim(),
                company: _companyController.text.trim(),
              ));
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.localizations});

  final AppLocalizations localizations;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.localizations;
    return themedAlert(
      context,
      AlertDialog(
        scrollable: true,
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(l.deleteAccountQuestion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.deleteAccountWarning),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(labelText: l.typeDeleteToConfirm),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(
              context,
              _confirmationController.text.trim() == 'DELETE',
            ),
            child: Text(l.deleteAccount),
          ),
        ],
      ),
    );
  }
}
