import 'dart:ui';

import 'package:flutter/material.dart';

final class AppConstants {
  const AppConstants._();

  static const String appName = 'وردي';
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );
  static const String laravelBaseUrl = String.fromEnvironment(
    'LARAVEL_BASE_URL',
    defaultValue: 'https://api.werdi.app/api',
  );
  static const bool useLaravelBackend = bool.fromEnvironment(
    'USE_LARAVEL_BACKEND',
    defaultValue: true,
  );
  static const Size designSize = Size(390, 844);
  static const Locale defaultLocale = Locale('ar');
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
}
