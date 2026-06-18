import 'package:flutter/material.dart';
import 'package:werdi/core/widgets/app_text.dart';

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidgets = trailing == null ? null : <Widget>[trailing!];
    return Row(
      children: [
        Expanded(
          child: AppText(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ...?trailingWidgets,
      ],
    );
  }
}
