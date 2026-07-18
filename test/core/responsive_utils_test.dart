import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/responsive/responsive_helper.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';

void main() {
  Widget wrap(Widget child, Size size) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        home: Builder(builder: (context) => child),
      ),
    );
  }

  testWidgets('detects mobile breakpoint and bottom nav', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      wrap(
        LayoutBuilder(builder: (ctx, _) {
          context = ctx;
          return const SizedBox.shrink();
        }),
        const Size(390, 844),
      ),
    );

    expect(ResponsiveHelper.isMobile(context), isTrue);
    expect(ResponsiveHelper.navChromeOf(context), NavChrome.bottom);
  });

  testWidgets('detects tablet breakpoint and rail nav', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      wrap(
        LayoutBuilder(builder: (ctx, _) {
          context = ctx;
          return const SizedBox.shrink();
        }),
        const Size(800, 1200),
      ),
    );

    expect(ResponsiveHelper.isTablet(context), isTrue);
    expect(ResponsiveHelper.navChromeOf(context), NavChrome.rail);
  });

  testWidgets('detects desktop breakpoint and side nav', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      wrap(
        LayoutBuilder(builder: (ctx, _) {
          context = ctx;
          return const SizedBox.shrink();
        }),
        const Size(1440, 900),
      ),
    );

    expect(ResponsiveHelper.isDesktop(context), isTrue);
    expect(ResponsiveHelper.navChromeOf(context), NavChrome.side);
  });

  testWidgets('detects small phone breakpoint', (tester) async {
    late BuildContext context;

    await tester.pumpWidget(
      wrap(
        LayoutBuilder(
          builder: (ctx, _) {
            context = ctx;
            return const SizedBox.shrink();
          },
        ),
        const Size(320, 640),
      ),
    );

    expect(ResponsiveUtils.isSmallPhone(context), isTrue);
    expect(ResponsiveHelper.isMobile(context), isTrue);
  });

  testWidgets('scales fonts up on larger screens', (tester) async {
    late double phoneFont;
    late double tabletFont;
    late double desktopFont;

    await tester.pumpWidget(
      wrap(
        LayoutBuilder(
          builder: (context, _) {
            phoneFont = ResponsiveHelper.adaptiveFont(context, 16);
            return const SizedBox.shrink();
          },
        ),
        const Size(360, 800),
      ),
    );

    await tester.pumpWidget(
      wrap(
        LayoutBuilder(
          builder: (context, _) {
            tabletFont = ResponsiveHelper.adaptiveFont(context, 16);
            return const SizedBox.shrink();
          },
        ),
        const Size(800, 1200),
      ),
    );

    await tester.pumpWidget(
      wrap(
        LayoutBuilder(
          builder: (context, _) {
            desktopFont = ResponsiveHelper.adaptiveFont(context, 16);
            return const SizedBox.shrink();
          },
        ),
        const Size(1440, 900),
      ),
    );

    expect(tabletFont, greaterThan(phoneFont));
    expect(desktopFont, greaterThan(tabletFont));
  });

  testWidgets('adaptive padding grows with device type', (tester) async {
    late double mobilePad;
    late double desktopPad;

    await tester.pumpWidget(
      wrap(
        LayoutBuilder(
          builder: (context, _) {
            mobilePad = ResponsiveHelper.adaptivePadding(context);
            return const SizedBox.shrink();
          },
        ),
        const Size(390, 844),
      ),
    );
    await tester.pumpWidget(
      wrap(
        LayoutBuilder(
          builder: (context, _) {
            desktopPad = ResponsiveHelper.adaptivePadding(context);
            return const SizedBox.shrink();
          },
        ),
        const Size(1440, 900),
      ),
    );

    expect(desktopPad, greaterThan(mobilePad));
  });
}
