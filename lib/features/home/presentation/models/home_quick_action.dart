import 'package:flutter/material.dart';

enum HomeQuickActionType { memorize, review, test, quran }

class HomeQuickAction {
  const HomeQuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final HomeQuickActionType type;
}
