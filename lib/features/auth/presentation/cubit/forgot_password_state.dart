import 'package:equatable/equatable.dart';
import 'package:werdi/features/auth/presentation/cubit/validators.dart';

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.showErrors = false,
    this.isSubmitting = false,
    this.didSubmitSuccessfully = false,
  });

  final String email;
  final bool showErrors;
  final bool isSubmitting;
  final bool didSubmitSuccessfully;

  bool get isValid => AuthValidators.isValidEmail(email);

  String? get emailError => showErrors && !AuthValidators.isValidEmail(email)
      ? 'أدخل بريد إلكتروني صحيح'
      : null;

  ForgotPasswordState copyWith({
    String? email,
    bool? showErrors,
    bool? isSubmitting,
    bool? didSubmitSuccessfully,
    bool clearResult = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
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
    showErrors,
    isSubmitting,
    didSubmitSuccessfully,
  ];
}
