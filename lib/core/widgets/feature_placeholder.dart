import 'package:flutter/material.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_text.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: AppText(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
