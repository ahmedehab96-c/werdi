import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.maxContentWidth = defaultMaxContentWidth,
  });

  /// Default cap for the content column on large (tablet/desktop/web) screens.
  /// Below this width (i.e. on phones) the constraint has no effect.
  static const double defaultMaxContentWidth = 1040;

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final EdgeInsetsGeometry? padding;

  /// Maximum width the [body] is allowed to occupy. Content is centered once
  /// the available width exceeds this value, keeping layouts readable on wide
  /// screens. Pass a smaller value for focused flows (e.g. forms).
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
