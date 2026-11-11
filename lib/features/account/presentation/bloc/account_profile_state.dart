enum AccountProfileStatus {
  initial,
  loading,
  loaded,
  failure,
  actionLoading,
  actionSuccess,
  actionFailure,
}

enum AccountProfileAction { save, passwordReset, signOut, delete }

class AccountProfileState {
  const AccountProfileState({
    this.status = AccountProfileStatus.initial,
    this.profile = const {},
    this.message,
    this.action,
    this.email,
  });

  final AccountProfileStatus status;
  final Map<String, dynamic> profile;
  final String? message;
  final AccountProfileAction? action;
  final String? email;
}
