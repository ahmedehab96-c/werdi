import 'package:flutter/widgets.dart';

/// Logical corner radii (density-independent).
final class AppRadius {
  const AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double full = 999;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get input => BorderRadius.circular(sm);
  static BorderRadius get iconContainer => BorderRadius.circular(sm);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get pill => BorderRadius.circular(full);
}
