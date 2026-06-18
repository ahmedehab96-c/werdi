import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320.w,
        child: AppSurfaceCard(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 10.h),
              AppText(message),
            ],
          ),
        ),
      ),
    );
  }
}
