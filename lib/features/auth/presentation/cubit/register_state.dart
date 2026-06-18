import 'package:equatable/equatable.dart';
import 'package:werdi/features/auth/presentation/cubit/validators.dart';

class RegisterState extends Equatable {
  const RegisterState({
    this.name = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.showErrors = false,
    this.isSubmitting = false,
    this.didSubmitSuccessfully = false,
  });

  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool showErrors;
  final bool isSubmitting;
  final bool didSubmitSuccessfully;

  bool get isValid =>
      name.trim().length >= 2 &&
      AuthValidators.isValidEmail(email) &&
      password.trim().length >= 6 &&
      password == confirmPassword;

  String? get nameError =>
      showErrors && name.trim().length < 2 ? 'الاسم قصير جدا' : null;
  String? get emailError => showErrors && !AuthValidators.isValidEmail(email)
      ? 'أدخل بريد إلكتروني صحيح'
      : null;
  String? get passwordError => showErrors && password.trim().length < 6
      ? 'كلمة المرور 6 أحرف على الأقل'
      : null;
  String? get confirmPasswordError => showErrors && password != confirmPassword
      ? 'كلمتا المرور غير متطابقتين'
      : null;

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? showErrors,
    bool? isSubmitting,
    bool? didSubmitSuccessfully,
    bool clearResult = false,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      showErrors: showErrors ?? this.showErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      didSubmitSuccessfully: clearResult
          ? false
          : (didSubmitSuccessfully ?? this.didSubmitSuccessfully),
    );
  }

  @override
  List<Object> get props => [
    name,
    email,
    password,
    confirmPassword,
    showErrors,
    isSubmitting,
    didSubmitSuccessfully,
  ];
}
