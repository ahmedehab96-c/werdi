import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/navigation/shell_tab_coordinator.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';

/// Adaptive app shell:
/// - Phone: bottom [NavigationBar]
/// - Tablet: [NavigationRail]
/// - Desktop: extended side [NavigationRail]
class AppShellScaffold extends StatelessWidget {
  AppShellScaffold({required StatefulNavigationShell navigationShell, super.key})
    : _currentIndex = navigationShell.currentIndex,
      _body = navigationShell,
      _onGoBranch = navigationShell.goBranch;

  const AppShellScaffold.testable({
    required int currentIndex,
    required Widget body,
    required void Function(int index, {bool initialLocation}) onGoBranch,
    super.key,
  }) : _currentIndex = currentIndex,
       _body = body,
       _onGoBranch = onGoBranch;

  final int _currentIndex;
  final Widget _body;
  final void Function(int index, {bool initialLocation}) _onGoBranch;

  void _onDestinationSelected(int index) {
    _onGoBranch(
      index,
      initialLocation: index == _currentIndex,
    );
    ShellTabCoordinator.notifyTabSelected(index);
  }

  List<_ShellDestination> _destinations(BuildContext context) {
    final l10n = context.l10n;
    return [
      _ShellDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.navHome,
      ),
      _ShellDestination(
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
        label: l10n.navQuran,
      ),
      _ShellDestination(
        icon: Icons.psychology_outlined,
        selectedIcon: Icons.psychology_rounded,
        label: l10n.navMemorization,
      ),
      _ShellDestination(
        icon: Icons.flag_outlined,
        selectedIcon: Icons.flag_rounded,
        label: l10n.navGoals,
      ),
      _ShellDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: l10n.navProfile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final chrome = ResponsiveHelper.navChromeOf(context);
    final destinations = _destinations(context);
    final iconSize = ResponsiveUtils.responsiveIconSize(context, 24);
    final isCompactPhone = ResponsiveHelper.isSmallPhone(context);
    final railExtendedWidth =
        ResponsiveHelper.adaptiveWidth(context, 220).clamp(184.0, 280.0);

    return switch (chrome) {
      NavChrome.bottom => Scaffold(
          body: SafeArea(child: _body),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            labelBehavior: isCompactPhone
                ? NavigationDestinationLabelBehavior.onlyShowSelected
                : NavigationDestinationLabelBehavior.alwaysShow,
            height: ResponsiveUtils.minTouchTargetSize(context) +
                ResponsiveUtils.responsiveSpacing(context, 28),
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: Icon(destination.icon, size: iconSize),
                  selectedIcon: Icon(destination.selectedIcon, size: iconSize),
                  label: destination.label,
                ),
            ],
          ),
        ),
      NavChrome.rail || NavChrome.side => Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  extended: chrome == NavChrome.side,
                  minExtendedWidth: railExtendedWidth,
                  labelType: chrome == NavChrome.side
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon, size: iconSize),
                        selectedIcon:
                            Icon(destination.selectedIcon, size: iconSize),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: _body),
              ],
            ),
          ),
        ),
    };
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Switches to a primary shell tab by route name.
extension AppShellNavigation on BuildContext {
  void goToShellTab(String routeName) => goNamed(routeName);
}
