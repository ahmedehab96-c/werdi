import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/constants/app_constants.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/home/presentation/cubit/home_state.dart';
import 'package:werdi/routes/app_routes.dart';

class HomeGreetingSection extends StatelessWidget {
  const HomeGreetingSection({required this.state, super.key});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final name = state.userName.isEmpty ? AppConstants.appName : state.userName;

    return Row(
      children: [
        Expanded(
          child: AppText(
            context.l10n.homeGreeting(name),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          tooltip: context.l10n.settingsTitle,
          onPressed: () => context.pushNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}
