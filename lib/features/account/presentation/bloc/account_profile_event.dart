sealed class AccountProfileEvent {
  const AccountProfileEvent();
}

final class LoadAccountProfile extends AccountProfileEvent {
  const LoadAccountProfile();
}

final class SaveAccountProfile extends AccountProfileEvent {
  const SaveAccountProfile({
    required this.displayName,
    required this.companyName,
  });

  final String displayName;
  final String companyName;
}

final class SendAccountPasswordReset extends AccountProfileEvent {
  const SendAccountPasswordReset(this.email);

  final String email;
}

final class SignOutAccount extends AccountProfileEvent {
  const SignOutAccount();
}

final class DeleteAccount extends AccountProfileEvent {
  const DeleteAccount();
}
