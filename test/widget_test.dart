import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/app.dart';

void main() {
  testWidgets('App boots and renders splash logo', (WidgetTester tester) async {
    await tester.pumpWidget(const WerdiApp());
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });
}
