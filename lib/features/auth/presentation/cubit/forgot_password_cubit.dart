import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';
import 'package:werdi/features/auth/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required AuthRepository repository})
    : _repository = repository,
      super(const ForgotPasswordState());

  final AuthRepository _repository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearResult: true));
  }

  Future<void> submit() async {
    final next = state.copyWith(showErrors: true, clearResult: true);
    if (!next.isValid) {
      emit(next);
      return;
    }
    try {
      emit(next.copyWith(isSubmitting: true));
      await _repository.sendPasswordReset(email: next.email.trim());
      emit(next.copyWith(isSubmitting: false, didSubmitSuccessfully: true));
    } catch (_) {
      emit(next.copyWith(isSubmitting: false, didSubmitSuccessfully: false));
    }
  }
}
