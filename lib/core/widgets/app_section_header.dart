import 'package:flutter/material.dart';
import 'package:werdi/core/widgets/app_text.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({required this.title, super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidgets = trailing == null ? <Widget>[] : <Widget>[trailing!];
    return Row(
      children: [
        Expanded(
          child: AppText(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        ...trailingWidgets,
      ],
    );
  }
}
