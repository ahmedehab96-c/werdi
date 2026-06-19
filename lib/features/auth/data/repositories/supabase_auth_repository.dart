import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'package:werdi/core/network/supabase_service.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({AppPreferences? preferences})
      : _preferences = preferences ?? const SharedPrefsService();

  final AppPreferences _preferences;
  static const _lastUserIdKey = 'auth_last_user_id';
  static const _lastUserNameKey = 'auth_last_user_name';
  static const _lastUserEmailKey = 'auth_last_user_email';

  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<AuthUser> continueAsGuest() async {
    return const AuthUser(id: 'guest', name: 'Guest', email: '', isGuest: true);
  }

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Registration failed');
      }
      final mapped = _mapUser(user, fallbackName: name);
      await _cacheUser(mapped);
      return mapped;
    } on AuthException catch (e) {
      if (_isConnectivityIssue(e)) {
        return _cacheAndReturnOfflineUser(name: name, email: email);
      }
      rethrow;
    } on SocketException {
      return _cacheAndReturnOfflineUser(name: name, email: email);
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      if (!_isConnectivityIssue(e)) rethrow;
    } on SocketException {
      // Ignore offline reset request.
    }
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Login failed');
      }
      final mapped = _mapUser(user);
      await _cacheUser(mapped);
      return mapped;
    } on AuthException catch (e) {
      if (_isConnectivityIssue(e)) {
        final cached = await _cachedUser();
        if (cached != null &&
            cached.email.toLowerCase() == email.trim().toLowerCase()) {
          return cached;
        }
      }
      rethrow;
    } on SocketException {
      final cached = await _cachedUser();
      if (cached != null &&
          cached.email.toLowerCase() == email.trim().toLowerCase()) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<AuthUser> getMe() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      final mapped = _mapUser(user);
      await _cacheUser(mapped);
      return mapped;
    }

    try {
      final response = await _client.auth.getUser();
      final remoteUser = response.user;
      if (remoteUser != null) {
        final mapped = _mapUser(remoteUser);
        await _cacheUser(mapped);
        return mapped;
      }
    } on AuthException catch (e) {
      if (_isConnectivityIssue(e)) {
        final cached = await _cachedUser();
        if (cached != null) return cached;
      }
      rethrow;
    } on SocketException {
      final cached = await _cachedUser();
      if (cached != null) return cached;
      rethrow;
    }

    final cached = await _cachedUser();
    if (cached != null) return cached;
    return continueAsGuest();
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // Clear local session even if remote sign-out fails.
    }
  }

  AuthUser _mapUser(User user, {String? fallbackName}) {
    final metadata = user.userMetadata ?? <String, dynamic>{};
    final name = (metadata['name'] as String?)?.trim();
    return AuthUser(
      id: user.id,
      name: (name == null || name.isEmpty)
          ? (fallbackName?.trim().isNotEmpty == true ? fallbackName!.trim() : 'مستخدم')
          : name,
      email: user.email ?? '',
      isGuest: false,
    );
  }

  Future<void> _cacheUser(AuthUser user) async {
    await _preferences.setString(_lastUserIdKey, user.id);
    await _preferences.setString(_lastUserNameKey, user.name);
    await _preferences.setString(_lastUserEmailKey, user.email);
  }

  Future<AuthUser?> _cachedUser() async {
    final id = await _preferences.getString(_lastUserIdKey);
    final name = await _preferences.getString(_lastUserNameKey);
    final email = await _preferences.getString(_lastUserEmailKey);
    if (id == null || id.isEmpty || email == null || email.isEmpty) {
      return null;
    }
    return AuthUser(
      id: id,
      name: (name == null || name.isEmpty) ? 'مستخدم' : name,
      email: email,
      isGuest: false,
    );
  }

  Future<AuthUser> _cacheAndReturnOfflineUser({
    required String name,
    required String email,
  }) async {
    final offline = AuthUser(
      id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'مستخدم' : name,
      email: email,
      isGuest: false,
    );
    await _cacheUser(offline);
    return offline;
  }

  bool _isConnectivityIssue(AuthException e) {
    final message = e.message.toLowerCase();
    return message.contains('network') ||
        message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection');
  }
}
