import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/theme/app_radius.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({
    required this.icon,
    super.key,
    this.size,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final double? size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size ?? 40.w,
      height: size ?? 40.w,
      decoration: BoxDecoration(
        color: background ?? scheme.primaryContainer,
        borderRadius: AppRadius.iconContainer,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20.sp, color: foreground ?? scheme.primary),
    );
  }
}
