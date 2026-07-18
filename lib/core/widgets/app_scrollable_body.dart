import 'package:flutter/material.dart';

/// Scrollable page body that avoids [Column] bottom overflow on short screens.
///
/// When [footer] is set, content scrolls above pinned actions.
/// Keyboard insets are respected so forms stay visible.
class AppScrollableBody extends StatelessWidget {
  const AppScrollableBody({
    required this.children,
    super.key,
    this.footer,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.physics,
  });

  final List<Widget> children;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final content = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );

    if (footer == null) {
      return SingleChildScrollView(
        padding: (padding ?? EdgeInsets.zero).add(
          EdgeInsets.only(bottom: keyboardInset),
        ),
        physics: physics ?? const BouncingScrollPhysics(),
        child: content,
      );
    }

    return Padding(
      padding: (padding ?? EdgeInsets.zero).add(
        EdgeInsets.only(bottom: keyboardInset),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: physics ?? const BouncingScrollPhysics(),
              child: content,
            ),
          ),
          footer!,
        ],
      ),
    );
  }
}
