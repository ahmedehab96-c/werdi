import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/navigation/shell_tab_coordinator.dart';
import 'package:werdi/core/widgets/app_shell_scaffold.dart';
import 'package:werdi/l10n/app_localizations.dart';

void main() {
  Future<void> pumpShell(
    WidgetTester tester, {
    required Size size,
    required Widget home,
  }) async {
    tester.view.physicalSize = Size(size.width * 3, size.height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
  }

  testWidgets('renders five primary shell tabs on phone', (tester) async {
    await pumpShell(
      tester,
      size: const Size(390, 844),
      home: AppShellScaffold.testable(
        currentIndex: 0,
        body: const SizedBox.shrink(),
        onGoBranch: (_, {initialLocation = false}) {},
      ),
    );

    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('uses navigation rail on tablet', (tester) async {
    await pumpShell(
      tester,
      size: const Size(800, 1200),
      home: AppShellScaffold.testable(
        currentIndex: 0,
        body: const SizedBox.shrink(),
        onGoBranch: (_, {initialLocation = false}) {},
      ),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNothing);
  });

  testWidgets('uses extended rail on desktop', (tester) async {
    await pumpShell(
      tester,
      size: const Size(1280, 800),
      home: AppShellScaffold.testable(
        currentIndex: 0,
        body: const SizedBox.shrink(),
        onGoBranch: (_, {initialLocation = false}) {},
      ),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isTrue);
  });

  testWidgets('tap on tab calls goBranch and tab hooks', (tester) async {
    int? selectedIndex;
    bool? selectedInitialLocation;
    var profileHookCalls = 0;
    ShellTabCoordinator.onProfileTabSelected = () => profileHookCalls++;

    await pumpShell(
      tester,
      size: const Size(390, 844),
      home: AppShellScaffold.testable(
        currentIndex: 0,
        body: const SizedBox.shrink(),
        onGoBranch: (index, {initialLocation = false}) {
          selectedIndex = index;
          selectedInitialLocation = initialLocation;
        },
      ),
    );

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pump();

    expect(selectedIndex, 4);
    expect(selectedInitialLocation, isFalse);
    expect(profileHookCalls, 1);

    ShellTabCoordinator.onProfileTabSelected = null;
  });
}
