import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/widgets/app_branded_background.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.maxContentWidth,
    this.brandedBackground = true,
  });

  /// Default cap for the content column on large screens.
  static const double defaultMaxContentWidth = 1040;

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final double? maxContentWidth;
  final bool brandedBackground;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final resolvedMaxWidth =
        maxContentWidth ?? Responsive.contentMaxWidth(context);
    final resolvedPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(context),
        );

    final content = LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: resolvedMaxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: resolvedPadding,
              child: body,
            ),
          ),
        );
      },
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: SafeArea(
          child: brandedBackground
              ? AppBrandedBackground(child: content)
              : content,
        ),
      ),
    );
  }
}
