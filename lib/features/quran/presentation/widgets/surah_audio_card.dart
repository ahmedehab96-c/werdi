import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/quran/domain/models/quran_audio_reciter.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';

class SurahAudioCard extends StatefulWidget {
  const SurahAudioCard({required this.surah, super.key});

  final SurahItem surah;

  @override
  State<SurahAudioCard> createState() => _SurahAudioCardState();
}

class _SurahAudioCardState extends State<SurahAudioCard> {
  bool _isPlaying = false;
  int _selectedAyah = 1;
  bool _isCheckingAvailability = false;
  bool? _isReciterAvailable;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuranCubit>().state;
    final cubit = context.read<QuranCubit>();
    final l10n = context.l10n;
    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: l10n.reciterVoices),
          SizedBox(height: 4.h),
          AppText(
            l10n.recitersSource,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 8.h),
          if (state.isLoadingAudioReciters)
            const LinearProgressIndicator()
          else if (state.audioReciters.isEmpty)
            AppText(l10n.recitersLoadError)
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.record_voice_over_rounded),
              title: AppText(
                state.selectedAudioReciter?.name ?? l10n.chooseReciter,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: AppText(
                l10n.reciterCountTapToSearch(state.audioReciters.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.search_rounded),
              onTap: () => _openReciterPicker(context, cubit),
            ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<int>(
            initialValue: _selectedAyah,
            items: List<int>.generate(widget.surah.verseCount, (i) => i + 1)
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(l10n.ayahNumbered(a)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _selectedAyah = v);
            },
            decoration: InputDecoration(
              labelText: l10n.ayahNumberLabel,
              prefixIcon: const Icon(Icons.format_list_numbered_rounded),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCheckingAvailability
                      ? null
                      : () => _checkAvailability(cubit),
                  icon: _isCheckingAvailability
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check_rounded),
                  label: Text(
                    _isCheckingAvailability
                        ? l10n.checking
                        : l10n.checkReciterAvailability,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              AppText(
                _isReciterAvailable == null
                    ? l10n.notChecked
                    : (_isReciterAvailable! ? l10n.available : l10n.unavailable),
                style: TextStyle(
                  color: _isReciterAvailable == null
                      ? Theme.of(context).hintColor
                      : (_isReciterAvailable! ? Colors.green : Colors.red),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppButton(
            label: _isPlaying ? l10n.stopAudio : l10n.playSelectedAyah,
            onPressed: () async {
              try {
                if (_isPlaying) {
                  await AppInjector.audioRepository.stop();
                  if (!mounted) return;
                  setState(() => _isPlaying = false);
                  return;
                }
                final urls = cubit.getAudioAyahUrls(
                  surahNumber: widget.surah.number,
                  ayahNumber: _selectedAyah,
                );
                if (urls.isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.waitOrChooseReciter),
                    ),
                  );
                  return;
                }
                await playAudioUrlsWithFallback(
                  AppInjector.audioRepository,
                  urls: urls,
                );
                if (!mounted) return;
                setState(() => _isPlaying = true);
              } catch (_) {
                if (!mounted) return;
                setState(() => _isReciterAvailable = false);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(l10n.cannotPlayAudio)),
                );
              }
            },
            icon: Icon(
              _isPlaying ? Icons.stop_circle_rounded : Icons.play_arrow_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAvailability(QuranCubit cubit) async {
    setState(() => _isCheckingAvailability = true);
    final urls = cubit.getAudioAyahUrls(
      surahNumber: widget.surah.number,
      ayahNumber: _selectedAyah,
    );
    if (urls.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isCheckingAvailability = false;
        _isReciterAvailable = false;
      });
      return;
    }
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    var available = false;
    for (final url in urls) {
      try {
        final head = await dio.head<void>(
          url,
          options: Options(
            validateStatus: (code) => code != null && code < 500,
          ),
        );
        if ((head.statusCode ?? 500) < 400) {
          available = true;
          break;
        }
        if (head.statusCode == 405) {
          final get = await dio.get<void>(
            url,
            options: Options(
              headers: const {'Range': 'bytes=0-1'},
              responseType: ResponseType.stream,
              validateStatus: (code) => code != null && code < 500,
            ),
          );
          if ((get.statusCode ?? 500) < 400) {
            available = true;
            break;
          }
        }
      } catch (_) {
        continue;
      }
    }
    if (!mounted) return;
    setState(() {
      _isCheckingAvailability = false;
      _isReciterAvailable = available;
    });
  }

  void _openReciterPicker(BuildContext context, QuranCubit cubit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _ReciterPickerSheet(
            reciters: cubit.state.audioReciters,
            selected: cubit.state.selectedAudioReciter,
            onPick: (r) {
              cubit.setSelectedAudioReciter(r);
              Navigator.pop(sheetContext);
            },
          ),
        );
      },
    );
  }
}

class _ReciterPickerSheet extends StatefulWidget {
  const _ReciterPickerSheet({
    required this.reciters,
    required this.selected,
    required this.onPick,
  });

  final List<QuranAudioReciter> reciters;
  final QuranAudioReciter? selected;
  final void Function(QuranAudioReciter) onPick;

  @override
  State<_ReciterPickerSheet> createState() => _ReciterPickerSheetState();
}

class _ReciterPickerSheetState extends State<_ReciterPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final filtered = q.isEmpty
        ? widget.reciters
        : widget.reciters.where((r) => r.name.contains(q)).toList();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: context.l10n.searchReciterHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: Responsive.valueFor(
              context,
              compact: 280,
              medium: 360,
              expanded: 420,
            ),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final r = filtered[index];
                final isSel = widget.selected?.mp3QuranId == r.mp3QuranId;
                return ListTile(
                  title: Text(r.name, textAlign: TextAlign.right),
                  subtitle: Text(
                    '${r.letter} • ${r.hasVerseLevelUrls ? context.l10n.ayahByAyah : context.l10n.fullSurahFile}',
                    textAlign: TextAlign.right,
                  ),
                  selected: isSel,
                  onTap: () => widget.onPick(r),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
