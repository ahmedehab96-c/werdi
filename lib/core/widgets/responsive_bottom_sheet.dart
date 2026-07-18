import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';

/// Shows a bottom sheet that adapts width on tablets and desktop.
Future<T?> showResponsiveBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    builder: (sheetContext) {
      final maxWidth = ResponsiveUtils.bottomSheetMaxWidth(sheetContext);
      final child = builder(sheetContext);
      if (ResponsiveHelper.isMobile(sheetContext)) return child;
      return Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    },
  );
}
