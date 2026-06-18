import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit({required this.totalPages}) : super(0);

  final int totalPages;

  bool get isLast => state == totalPages - 1;

  void setPage(int index) {
    if (index < 0 || index >= totalPages) return;
    emit(index);
  }

  void next() {
    if (isLast) return;
    emit(state + 1);
  }

  void skip() {
    emit(totalPages - 1);
  }
}
