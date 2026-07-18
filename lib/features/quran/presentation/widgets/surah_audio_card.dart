import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:werdi/core/theme/app_spacing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:werdi/core/audio/audio_playback.dart';
import 'package:werdi/core/audio/quran_audio_session.dart';
import 'package:werdi/core/responsive/responsive.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_button.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/core/widgets/responsive_bottom_sheet.dart';
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
  bool _isPlaylistActive = false;
  int? _playlistAyah;
  int _selectedAyah = 1;
  int _rangeEndAyah = 1;
  bool _isCheckingAvailability = false;
  bool? _isReciterAvailable;

  @override
  void initState() {
    super.initState();
    _rangeEndAyah = widget.surah.verseCount;
  }

  @override
  void dispose() {
    QuranAudioSession.clear();
    unawaited(AppInjector.ayahPlaylistPlayer.stop());
    unawaited(AppInjector.audioRepository.stop());
    super.dispose();
  }

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
          const SizedBox(height: AppSpacing.xxs),
          AppText(
            l10n.recitersSource,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.isLoadingAudioReciters)
            const LinearProgressIndicator()
          else if (state.audioReciters.isEmpty)
            AppText(l10n.recitersLoadError)
          else
            InkWell(
              onTap: () => _openReciterPicker(context, cubit),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            state.selectedAudioReciter?.name ??
                                l10n.chooseReciter,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          AppText(
                            l10n.reciterCountTapToSearch(
                              state.audioReciters.length,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.search_rounded),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            initialValue: _selectedAyah,
            isExpanded: true,
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
              setState(() {
                _selectedAyah = v;
                if (_rangeEndAyah < v) _rangeEndAyah = v;
              });
            },
            decoration: InputDecoration(
              labelText: l10n.fromAyah,
              prefixIcon: const Icon(Icons.format_list_numbered_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            key: ValueKey('end_$_selectedAyah$_rangeEndAyah'),
            initialValue: _rangeEndAyah.clamp(_selectedAyah, widget.surah.verseCount),
            isExpanded: true,
            items: List<int>.generate(
              widget.surah.verseCount - _selectedAyah + 1,
              (i) => _selectedAyah + i,
            )
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(l10n.ayahNumbered(a)),
                  ),
                )
                .toList(),
            onChanged: _isPlaylistActive
                ? null
                : (v) {
                    if (v == null) return;
                    setState(() => _rangeEndAyah = v);
                  },
            decoration: InputDecoration(
              labelText: l10n.toAyah,
              prefixIcon: const Icon(Icons.last_page_rounded),
            ),
          ),
          if (_isPlaylistActive && _playlistAyah != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText(
              l10n.playlistActiveAyah(_playlistAyah!),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
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
              const SizedBox(width: AppSpacing.xs),
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
          const SizedBox(height: AppSpacing.xs),
          AppButton(
            label: _isPlaying && !_isPlaylistActive
                ? l10n.stopAudio
                : l10n.playSelectedAyah,
            onPressed: _isPlaylistActive
                ? null
                : () async {
                    try {
                      if (_isPlaying) {
                        await _stopPlayback();
                        return;
                      }
                      await _playSelectedAyah(cubit);
                    } catch (_) {
                      if (!mounted) return;
                      setState(() => _isReciterAvailable = false);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(l10n.cannotPlayAudio)),
                      );
                    }
                  },
            icon: Icon(
              _isPlaying && !_isPlaylistActive
                  ? Icons.stop_circle_rounded
                  : Icons.play_arrow_rounded,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPlaying && !_isPlaylistActive
                      ? null
                      : () => _toggleRangePlayback(cubit),
                  icon: Icon(
                    _isPlaylistActive
                        ? Icons.stop_circle_outlined
                        : Icons.queue_music_rounded,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isPlaylistActive ? l10n.stopAudio : l10n.playAyahRange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPlaylistActive
                      ? () => _stopPlayback()
                      : _isPlaying
                          ? null
                          : () => _playFullSurah(cubit),
                  icon: Icon(
                    _isPlaylistActive
                        ? Icons.stop_circle_outlined
                        : Icons.menu_book_rounded,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isPlaylistActive ? l10n.stopAudio : l10n.playFullSurah,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _playSelectedAyah(QuranCubit cubit) async {
    final l10n = context.l10n;
    final urls = cubit.getAudioAyahUrls(
      surahNumber: widget.surah.number,
      ayahNumber: _selectedAyah,
    );
    if (urls.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.waitOrChooseReciter)),
      );
      return;
    }
    final reciter = cubit.state.selectedAudioReciter;
    setState(() {
      _isPlaying = false;
      _isPlaylistActive = false;
    });
    try {
      await playAudioUrlsWithFallback(
        AppInjector.audioRepository,
        urls: urls,
        metadata: reciter == null
            ? null
            : AyahPlaybackMetadata(
                surahNumber: widget.surah.number,
                surahNameArabic: widget.surah.nameArabic,
                ayahNumber: _selectedAyah,
                reciterName: reciter.name,
              ),
        onSkipNext: _selectedAyah < widget.surah.verseCount
            ? () async {
                if (!mounted) return;
                setState(() => _selectedAyah++);
                await _playSelectedAyah(cubit);
              }
            : null,
        onSkipPrevious: _selectedAyah > 1
            ? () async {
                if (!mounted) return;
                setState(() => _selectedAyah--);
                await _playSelectedAyah(cubit);
              }
            : null,
      );
      if (!mounted) return;
      setState(() => _isPlaying = true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _isPlaylistActive = false;
        _isReciterAvailable = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotPlayAudio)),
      );
    }
  }

  Future<void> _stopPlayback() async {
    if (_isPlaylistActive) {
      await AppInjector.ayahPlaylistPlayer.stop();
    } else {
      await AppInjector.audioRepository.stop();
    }
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _isPlaylistActive = false;
      _playlistAyah = null;
    });
  }

  Future<void> _toggleRangePlayback(QuranCubit cubit) async {
    if (_isPlaylistActive) {
      await _stopPlayback();
      return;
    }
    final end = _rangeEndAyah.clamp(_selectedAyah, widget.surah.verseCount);
    await _startRangePlayback(cubit, start: _selectedAyah, end: end);
  }

  Future<void> _playFullSurah(QuranCubit cubit) async {
    final l10n = context.l10n;
    final reciter = cubit.state.selectedAudioReciter;
    if (reciter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.waitOrChooseReciter)),
      );
      return;
    }

    // Full-surah file reciters: play the single surah MP3.
    if (!reciter.supportsAyahPlayback) {
      final padded = widget.surah.number.toString().padLeft(3, '0');
      final url = '${reciter.serverBaseUrl}$padded.mp3';
      try {
        await playAudioUrlsWithFallback(
          AppInjector.audioRepository,
          urls: [url],
          metadata: AyahPlaybackMetadata(
            surahNumber: widget.surah.number,
            surahNameArabic: widget.surah.nameArabic,
            ayahNumber: 1,
            reciterName: reciter.name,
          ),
        );
        if (!mounted) return;
        setState(() {
          _isPlaying = true;
          _isPlaylistActive = false;
          _playlistAyah = null;
          _selectedAyah = 1;
          _rangeEndAyah = widget.surah.verseCount;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isReciterAvailable = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cannotPlayAudio)),
        );
      }
      return;
    }

    setState(() {
      _selectedAyah = 1;
      _rangeEndAyah = widget.surah.verseCount;
    });
    // Always start a fresh playlist for full-surah (don't toggle-stop).
    if (_isPlaylistActive || _isPlaying) {
      await _stopPlayback();
    }
    await _startRangePlayback(cubit, start: 1, end: widget.surah.verseCount);
  }

  Future<void> _startRangePlayback(
    QuranCubit cubit, {
    required int start,
    required int end,
  }) async {
    final l10n = context.l10n;
    final reciter = cubit.state.selectedAudioReciter;
    if (reciter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.waitOrChooseReciter)),
      );
      return;
    }
    if (!reciter.supportsAyahPlayback) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotPlayAudio)),
      );
      return;
    }
    final startUrls = cubit.getAudioAyahUrls(
      surahNumber: widget.surah.number,
      ayahNumber: start,
    );
    if (startUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotPlayAudio)),
      );
      return;
    }

    setState(() {
      _selectedAyah = start;
      _rangeEndAyah = end;
      _isPlaylistActive = true;
      _isPlaying = true;
      _playlistAyah = start;
    });

    try {
      await AppInjector.ayahPlaylistPlayer.playRange(
        surahNumber: widget.surah.number,
        surahNameArabic: widget.surah.nameArabic,
        startAyah: start,
        endAyah: end,
        reciter: reciter,
        urlResolver: (ayah) => cubit.getAudioAyahUrls(
          surahNumber: widget.surah.number,
          ayahNumber: ayah,
        ),
        onAyahChanged: (ayah) {
          if (!mounted) return;
          setState(() {
            _playlistAyah = ayah;
            _selectedAyah = ayah;
          });
        },
        onCompleted: () {
          if (!mounted) return;
          setState(() {
            _isPlaylistActive = false;
            _isPlaying = false;
            _playlistAyah = null;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPlaylistActive = false;
        _isPlaying = false;
        _playlistAyah = null;
        _isReciterAvailable = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotPlayAudio)),
      );
    }
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
    showResponsiveBottomSheet<void>(
      context: context,
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
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
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
