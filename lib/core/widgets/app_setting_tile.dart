import 'package:flutter/material.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';

class AppSettingTile extends StatelessWidget {
  const AppSettingTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        trailing: trailing,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      ),
    );
  }
}
