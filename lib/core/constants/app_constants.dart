import 'dart:ui';

import 'package:flutter/material.dart';

final class AppConstants {
  const AppConstants._();

  static const String appName = 'وردي';
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static bool get useSupabaseBackend =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static const Size designSize = Size(390, 844);
  static const Locale defaultLocale = Locale('ar');
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
}
