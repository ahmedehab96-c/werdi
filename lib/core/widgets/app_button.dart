import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';
import 'package:werdi/core/theme/app_durations.dart';
import 'package:werdi/core/widgets/app_text.dart';

enum AppButtonVariant { primary, outlined, text, danger }

class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final AppButtonVariant variant;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final minHeight = ResponsiveUtils.minTouchTargetSize(context);
    final iconGap = ResponsiveUtils.responsiveSpacing(context, 8);
    final loaderSize = ResponsiveUtils.responsiveIconSize(context, 20);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: AppDurations.instant,
        curve: Curves.easeOutBack,
        scale: _pressed ? 0.96 : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: double.infinity,
            minHeight: minHeight,
          ),
          child: _buildButton(context, iconGap, loaderSize),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    double iconGap,
    double loaderSize,
  ) {
    final child = widget.isLoading
        ? SizedBox(
            width: loaderSize,
            height: loaderSize,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                SizedBox(width: iconGap),
              ],
              Flexible(
                child: AppText(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          );
    final onPressed = widget.isLoading ? null : widget.onPressed;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(onPressed: onPressed, child: child);
      case AppButtonVariant.outlined:
        return OutlinedButton(onPressed: onPressed, child: child);
      case AppButtonVariant.text:
        return TextButton(onPressed: onPressed, child: child);
      case AppButtonVariant.danger:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: onPressed,
          child: child,
        );
    }
  }
}
