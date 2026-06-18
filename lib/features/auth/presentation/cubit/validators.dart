final class AuthValidators {
  const AuthValidators._();

  static bool isValidEmail(String input) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(input.trim());
  }
}
