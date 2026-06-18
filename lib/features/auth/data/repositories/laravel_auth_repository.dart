import 'package:dio/dio.dart';
import 'package:werdi/core/network/laravel_api_client.dart';
import 'package:werdi/core/security/auth_token_store.dart';
import 'package:werdi/core/services/app_preferences.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';

class LaravelAuthRepository implements AuthRepository {
  LaravelAuthRepository({
    required LaravelApiClient client,
    required AuthTokenStore tokenStore,
    AppPreferences? preferences,
  }) : _client = client,
       _tokenStore = tokenStore,
       _preferences = preferences ?? const SharedPrefsService();

  final LaravelApiClient _client;
  final AuthTokenStore _tokenStore;
  final AppPreferences _preferences;
  static const _lastUserIdKey = 'auth_last_user_id';
  static const _lastUserNameKey = 'auth_last_user_name';
  static const _lastUserEmailKey = 'auth_last_user_email';

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
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      return _mapUserAndToken(response.data);
    } on DioException catch (e) {
      if (_isConnectivityIssue(e)) {
        return _cacheAndReturnOfflineUser(
          name: name,
          email: email,
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _client.dio.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      if (!_isConnectivityIssue(e)) rethrow;
    }
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _mapUserAndToken(response.data);
    } on DioException catch (e) {
      if (_isConnectivityIssue(e)) {
        final cached = await _cachedUser();
        if (cached != null &&
            cached.email.toLowerCase() == email.trim().toLowerCase()) {
          return cached;
        }
      }
      rethrow;
    }
  }

  @override
  Future<AuthUser> getMe() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/user');
      final user = response.data ?? <String, dynamic>{};
      final mapped = AuthUser(
        id: '${user['id'] ?? ''}',
        name: '${user['name'] ?? ''}',
        email: '${user['email'] ?? ''}',
        isGuest: false,
      );
      await _cacheUser(mapped);
      return mapped;
    } on DioException catch (e) {
      if (_isConnectivityIssue(e)) {
        final cached = await _cachedUser();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.dio.post('/auth/logout');
    } on DioException {
      // Ignore network/logout edge failures and clear token locally.
    } finally {
      _client.setToken(null);
      await _tokenStore.clearToken();
    }
  }

  AuthUser _mapUserAndToken(Map<String, dynamic>? data) {
    final payload = data ?? <String, dynamic>{};
    final token =
        payload['token'] as String? ?? payload['access_token'] as String? ?? '';
    final user = (payload['user'] as Map?)?.cast<String, dynamic>() ?? payload;
    _client.setToken(token);
    if (token.isNotEmpty) {
      _tokenStore.saveToken(token);
    }
    final authUser = AuthUser(
      id: '${user['id'] ?? ''}',
      name: '${user['name'] ?? ''}',
      email: '${user['email'] ?? ''}',
      isGuest: false,
    );
    _cacheUser(authUser);
    return authUser;
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

  bool _isConnectivityIssue(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }
}
