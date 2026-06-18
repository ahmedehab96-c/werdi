import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final class AppRadius {
  const AppRadius._();

  static double get xs => 8.r;
  static double get sm => 12.r;
  static double get md => 16.r;
  static double get lg => 20.r;
  static double get xl => 24.r;
  static double get full => 999.r;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get input => BorderRadius.circular(sm);
  static BorderRadius get iconContainer => BorderRadius.circular(sm);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get pill => BorderRadius.circular(full);
}
