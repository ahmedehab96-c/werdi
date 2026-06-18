import 'package:flutter/material.dart';
import 'package:werdi/l10n/app_localizations.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Localized strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
