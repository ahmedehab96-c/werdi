import 'package:flutter_screenutil/flutter_screenutil.dart';

final class AppSpacing {
  const AppSpacing._();

  // 4pt base grid scale
  static double get s1 => 4.w;
  static double get s2 => 8.w;
  static double get s3 => 12.w;
  static double get s4 => 16.w;
  static double get s5 => 20.w;
  static double get s6 => 24.w;
  static double get s8 => 32.w;
  static double get s10 => 40.w;
  static double get s12 => 48.w;
  static double get s16 => 64.w;

  // Semantic aliases
  static double get xxs => s1;
  static double get xs => s2;
  static double get sm => s3;
  static double get md => s4;
  static double get lg => s6;
  static double get xl => s8;
  static double get xxl => s10;
}
