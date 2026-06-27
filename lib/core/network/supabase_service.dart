import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/constants/app_constants.dart';

final class SupabaseService {
  const SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured => AppConstants.useSupabaseBackend;

  /// True only after [initialize] completes successfully.
  static bool get isReady => _initialized;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabaseAnonKey,
      );
      _initialized = true;
    } catch (_) {
      // Keep app usable offline/local if remote auth init fails.
    }
  }

  static SupabaseClient? get clientOrNull =>
      _initialized ? Supabase.instance.client : null;

  static SupabaseClient get client {
    final c = clientOrNull;
    if (c == null) {
      throw StateError('Supabase is not initialized');
    }
    return c;
  }

  static String? get currentUserId => clientOrNull?.auth.currentUser?.id;

  static bool get hasSession {
    final session = clientOrNull?.auth.currentSession;
    return session != null;
  }
}
