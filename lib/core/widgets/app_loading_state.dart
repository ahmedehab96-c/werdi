import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.contentMaxWidth(context).clamp(0, 360),
        ),
        child: AppSurfaceCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 10)),
              AppText(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
