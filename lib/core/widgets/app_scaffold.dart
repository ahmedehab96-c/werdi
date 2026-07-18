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
    this.resizeToAvoidBottomInset = true,
    /// When true (default), applies horizontal page inset only.
    /// Pages should add their own vertical / list padding.
    this.applyHorizontalInset = true,
  });

  /// Default cap for the content column on large screens.
  static const double defaultMaxContentWidth = 1200;

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;
  final double? maxContentWidth;
  final bool brandedBackground;
  final bool resizeToAvoidBottomInset;
  final bool applyHorizontalInset;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final resolvedMaxWidth =
        maxContentWidth ?? ResponsiveHelper.contentMaxWidth(context);
    final resolvedPadding = padding ??
        (applyHorizontalInset
            ? EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.adaptivePadding(context),
              )
            : EdgeInsets.zero);

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
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          child: brandedBackground
              ? AppBrandedBackground(child: content)
              : content,
        ),
      ),
    );
  }
}
