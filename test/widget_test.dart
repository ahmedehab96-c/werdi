import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/theme/app_theme.dart';

void main() {
  test('AppTheme motion duration is configured', () {
    expect(AppTheme.motionDuration.inMilliseconds, greaterThan(0));
  });
}
