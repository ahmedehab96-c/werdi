import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/features/auth/domain/repositories/auth_repository.dart';
import 'package:werdi/features/auth/presentation/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required AuthRepository repository})
    : _repository = repository,
      super(const RegisterState());

  final AuthRepository _repository;

  void nameChanged(String value) =>
      emit(state.copyWith(name: value, clearResult: true));
  void emailChanged(String value) =>
      emit(state.copyWith(email: value, clearResult: true));
  void passwordChanged(String value) =>
      emit(state.copyWith(password: value, clearResult: true));
  void confirmPasswordChanged(String value) =>
      emit(state.copyWith(confirmPassword: value, clearResult: true));

  Future<void> submit() async {
    final next = state.copyWith(showErrors: true, clearResult: true);
    if (!next.isValid) {
      emit(next);
      return;
    }
    try {
      emit(next.copyWith(isSubmitting: true));
      await _repository.registerWithEmail(
        name: next.name.trim(),
        email: next.email.trim(),
        password: next.password,
      );
      emit(next.copyWith(isSubmitting: false, didSubmitSuccessfully: true));
    } catch (_) {
      emit(next.copyWith(isSubmitting: false, didSubmitSuccessfully: false));
    }
  }
}
