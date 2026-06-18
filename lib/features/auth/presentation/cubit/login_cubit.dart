import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';
import 'package:werdi/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required AuthRepository repository})
    : _repository = repository,
      super(const LoginState());

  final AuthRepository _repository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearResult: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearResult: true));
  }

  Future<void> submit() async {
    final next = state.copyWith(showErrors: true, clearResult: true);
    if (!next.isValid) {
      emit(next);
      return;
    }
    try {
      emit(next.copyWith(isSubmitting: true));
      await _repository.signInWithEmail(
        email: next.email.trim(),
        password: next.password,
      );
      emit(next.copyWith(isSubmitting: false, didSubmitSuccessfully: true));
    } catch (_) {
      emit(next.copyWith(isSubmitting: false, didSubmitSuccessfully: false));
    }
  }
}
