import 'package:flutter_test/flutter_test.dart';
import 'package:werdi/core/navigation/shell_tab_coordinator.dart';

void main() {
  test('notifyTabSelected invokes home and profile hooks', () {
    var homeCalls = 0;
    var profileCalls = 0;

    ShellTabCoordinator.onHomeTabSelected = () => homeCalls++;
    ShellTabCoordinator.onProfileTabSelected = () => profileCalls++;

    ShellTabCoordinator.notifyTabSelected(0);
    ShellTabCoordinator.notifyTabSelected(4);
    ShellTabCoordinator.notifyTabSelected(2);

    expect(homeCalls, 1);
    expect(profileCalls, 1);

    ShellTabCoordinator.onHomeTabSelected = null;
    ShellTabCoordinator.onProfileTabSelected = null;
  });
}
