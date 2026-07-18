/// Lightweight hooks for refreshing shell tabs when the user switches to them.
abstract final class ShellTabCoordinator {
  static void Function()? onHomeTabSelected;
  static void Function()? onProfileTabSelected;

  static void notifyTabSelected(int index) {
    switch (index) {
      case 0:
        onHomeTabSelected?.call();
      case 4:
        onProfileTabSelected?.call();
    }
  }
}
