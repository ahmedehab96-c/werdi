import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:werdi/core/constants/app_constants.dart';

final class SupabaseService {
  const SupabaseService._();

  static bool get isConfigured => AppConstants.useSupabaseBackend;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      publishableKey: AppConstants.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? get currentUserId => client.auth.currentUser?.id;

  static bool get hasSession => client.auth.currentSession != null;
}
