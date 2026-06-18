import 'package:equatable/equatable.dart';
import 'package:werdi/features/auth/presentation/cubit/validators.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.showErrors = false,
    this.isSubmitting = false,
    this.didSubmitSuccessfully = false,
  });

  final String email;
  final String password;
  final bool showErrors;
  final bool isSubmitting;
  final bool didSubmitSuccessfully;

  bool get isValid =>
      AuthValidators.isValidEmail(email) && password.trim().length >= 6;

  String? get emailError => showErrors && !AuthValidators.isValidEmail(email)
      ? 'أدخل بريد إلكتروني صحيح'
      : null;

  String? get passwordError => showErrors && password.trim().length < 6
      ? 'كلمة المرور 6 أحرف على الأقل'
      : null;

  LoginState copyWith({
    String? email,
    String? password,
    bool? showErrors,
    bool? isSubmitting,
    bool? didSubmitSuccessfully,
    bool clearResult = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      showErrors: showErrors ?? this.showErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      didSubmitSuccessfully: clearResult
          ? false
          : (didSubmitSuccessfully ?? this.didSubmitSuccessfully),
    );
  }

  @override
  List<Object> get props => [
    email,
    password,
    showErrors,
    isSubmitting,
    didSubmitSuccessfully,
  ];
}
