import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/widgets/app_error_state.dart';

void main() {
  Widget wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('renders title and message', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppErrorState(
          title: 'Something went wrong',
          message: 'Please try again later',
          retryLabel: 'Retry',
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Please try again later'), findsOneWidget);
  });

  testWidgets('hides retry button when no callback is provided',
      (tester) async {
    await tester.pumpWidget(
      wrap(const AppErrorState(message: 'No retry here')),
    );

    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('invokes onRetry when the retry button is tapped',
      (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      wrap(
        AppErrorState(
          message: 'Tap to retry',
          retryLabel: 'Retry',
          onRetry: () => tapped++,
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(tapped, 1);
  });
}
