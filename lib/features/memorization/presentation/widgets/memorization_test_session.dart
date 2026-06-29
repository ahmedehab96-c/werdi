import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/features/memorization/presentation/cubit/memorization_state.dart';
import 'package:werdi/features/tasmee3/presentation/cubit/tasmee3_cubit.dart';
import 'package:werdi/features/tasmee3/presentation/cubit/tasmee3_state.dart';
import 'package:werdi/features/tasmee3/presentation/pages/tasmee3_page.dart';

/// Block tasmee3 embedded in memorization (same surah/range).
class MemorizationTestSession extends StatefulWidget {
  const MemorizationTestSession({required this.memState, super.key});

  final MemorizationState memState;

  @override
  State<MemorizationTestSession> createState() => _MemorizationTestSessionState();
}

class _MemorizationTestSessionState extends State<MemorizationTestSession> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = Tasmee3Cubit(
          repository: AppInjector.tasmee3Gateway,
          quranRepository: AppInjector.quranRepository,
          audioRepository: AppInjector.audioRepository,
          progressRepository: AppInjector.userProgressGateway,
          preferences: AppInjector.appPreferences,
        );
        cubit.syncSelection(
          surahName: widget.memState.selectedSurahName,
          surahNumber: widget.memState.selectedSurahNumber,
          ayahStart: widget.memState.ayahStart,
          ayahEnd: widget.memState.ayahEnd,
        );
        unawaited(cubit.startTest());
        return cubit;
      },
      child: BlocBuilder<Tasmee3Cubit, Tasmee3State>(
        builder: (context, tState) {
          if (tState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return switch (tState.status) {
            Tasmee3FlowStatus.testing => Tasmee3TestingScreen(state: tState),
            Tasmee3FlowStatus.summary => Tasmee3SummaryScreen(state: tState),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
