import 'package:werdi/core/network/supabase_service.dart';

/// Whether the app can read/write the signed-in user's Supabase data.
bool get canSyncWithSupabase =>
    SupabaseService.isReady &&
    SupabaseService.hasSession &&
    SupabaseService.currentUserId != null;

String? get supabaseUserId => SupabaseService.currentUserId;
