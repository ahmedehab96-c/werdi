abstract interface class AuthRepository {
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset({required String email});

  Future<AuthUser> continueAsGuest();

  Future<AuthUser> getMe();

  Future<void> signOut();
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isGuest,
  });

  final String id;
  final String name;
  final String email;
  final bool isGuest;
}
