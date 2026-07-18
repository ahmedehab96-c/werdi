import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';

/// Shows a dialog constrained and scrollable across phones, tablets, and desktop.
Future<T?> showResponsiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      final maxHeight = MediaQuery.sizeOf(dialogContext).height * 0.85;
      return Dialog(
        insetPadding: ResponsiveUtils.dialogInsetPadding(dialogContext),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.dialogMaxWidth(dialogContext),
            maxHeight: maxHeight,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(dialogContext).bottom,
            ),
            child: builder(dialogContext),
          ),
        ),
      );
    },
  );
}
