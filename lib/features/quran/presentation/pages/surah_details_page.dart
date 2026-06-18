import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran/quran.dart' as quran_pkg;
import 'package:werdi/core/utils/arabic_text_normalizer.dart';
import 'package:werdi/core/di/app_injector.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/core/widgets/app_animated_progress.dart';
import 'package:werdi/core/widgets/app_empty_state.dart';
import 'package:werdi/core/widgets/app_scaffold.dart';
import 'package:werdi/core/widgets/app_section_header.dart';
import 'package:werdi/core/widgets/app_surface_card.dart';
import 'package:werdi/core/widgets/app_text.dart';
import 'package:werdi/features/memorization/presentation/pages/memorization_page.dart';
import 'package:werdi/features/quran/domain/models/surah_item.dart';
import 'package:werdi/features/quran/presentation/cubit/quran_cubit.dart';
import 'package:werdi/features/quran/domain/models/quran_verse.dart';
import 'package:werdi/features/quran/presentation/widgets/surah_audio_card.dart';
import 'package:werdi/features/quran/presentation/widgets/surah_tafsir_card.dart';
import 'package:werdi/features/review/presentation/pages/review_page.dart';

class SurahDetailsPage extends StatefulWidget {
  const SurahDetailsPage({
    required this.surah,
    this.initialAyahNumber,
    this.initialSearchQuery,
    this.centerInitialAyah = false,
    this.startInFocusMode = false,
    super.key,
  });

  final SurahItem surah;
  final int? initialAyahNumber;
  final String? initialSearchQuery;
  final bool centerInitialAyah;
  final bool startInFocusMode;

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  int? _playingAyah;
  late final List<QuranVerse> _fallbackVerses;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = <int, GlobalKey>{};
  int? _highlightedAyah;
  Timer? _highlightTimer;
  bool _didJumpToInitialAyah = false;
  late bool _focusMode;
  double _focusFontScale = 1.0;
  double _focusLineHeight = 1.9;
  bool _focusSepia = false;
  Timer? _focusPrefsDebounce;

  static const _focusFontScaleKey = 'quran_focus_font_scale';
  static const _focusLineHeightKey = 'quran_focus_line_height';
  static const _focusSepiaKey = 'quran_focus_sepia_enabled';
  static const _unifiedReadingPrefsKey = 'settings_unified_reading_preferences';
  static const _defaultFocusFontScale = 1.0;
  static const _defaultFocusLineHeight = 1.9;
  static const _defaultFocusSepia = false;
  bool _useUnifiedReadingPrefs = false;

  @override
  void initState() {
    super.initState();
    _focusMode = widget.startInFocusMode;
    _fallbackVerses = _buildFallbackVerses();
    _loadFocusPreferences();
    context.read<QuranCubit>().loadSurahVerses(widget.surah.number);
  }

  @override
  Widget build(BuildContext context) {
    final ranges = context.read<QuranCubit>().buildSurahRanges(
      widget.surah.number,
    );
    final quranState = context.watch<QuranCubit>().state;
    final verses = quranState.currentSurahVerses.isNotEmpty
        ? quranState.currentSurahVerses
        : _fallbackVerses;
    _maybeJumpToInitialAyah(verses);
    final isBookmarked =
        quranState.bookmarkedSurahIds.contains(widget.surah.number);

    final l10n = context.l10n;
    final focusBackgroundColor = _focusSepia
        ? const Color(0xFFF7F0DD)
        : Theme.of(context).scaffoldBackgroundColor;
    final bodyList = ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      children: [
        if (!_focusMode) ...[
          // ── معلومات السورة
          AppSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  widget.surah.nameArabic,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                AppText(
                  '${widget.surah.nameEnglish} • ${l10n.ayahUnit(widget.surah.verseCount)} • ${widget.surah.revelationPlace}',
                ),
                SizedBox(height: 12.h),
                AppAnimatedProgress(value: widget.surah.progress),
                SizedBox(height: 8.h),
                AppText(
                  l10n.progressPercent((widget.surah.progress * 100).round()),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ── أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MemorizationPage(
                        initialSurahNumber: widget.surah.number,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.school_rounded),
                  label: Text(l10n.startMemorizing),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReviewPage(),
                    ),
                  ),
                  icon: const Icon(Icons.history_edu_rounded),
                  label: Text(l10n.startReview),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
        ],

        // ── آيات السورة
        AppSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionHeader(title: l10n.surahAyahs),
              SizedBox(height: 8.h),
              if (quranState.isLoadingSurahVerses)
                const Center(child: CircularProgressIndicator())
              else if (verses.isEmpty)
                AppEmptyState(
                  title: l10n.versesLoadError,
                  subtitle: l10n.versesLoadErrorSubtitle,
                  icon: Icons.menu_book_rounded,
                  action: FilledButton.icon(
                    onPressed: () => context.read<QuranCubit>().loadSurahVerses(
                          widget.surah.number,
                        ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(context.l10n.retry),
                  ),
                )
              else
                ...verses.map(
                  (verse) {
                    final isHighlighted = _highlightedAyah == verse.ayahNumber;
                    return AnimatedContainer(
                      key: _keyForAyah(verse.ayahNumber),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: isHighlighted ? 8.w : 0,
                        vertical: isHighlighted ? 4.h : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.45)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final cubit = context.read<QuranCubit>();
                              try {
                                if (_playingAyah == verse.ayahNumber) {
                                  await AppInjector.audioRepository.stop();
                                  if (!mounted) return;
                                  setState(() => _playingAyah = null);
                                  return;
                                }
                                await AppInjector.audioRepository.stop();
                                final urls = cubit.getAudioVerseUrls(
                                  surahNumber: widget.surah.number,
                                  ayahNumber: verse.ayahNumber,
                                );
                                if (urls.isEmpty) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.chooseReciterBelow),
                                    ),
                                  );
                                  return;
                                }
                                await _playWithFallback(
                                  urls: urls,
                                  onSuccess: () => setState(
                                    () => _playingAyah = verse.ayahNumber,
                                  ),
                                );
                                if (!mounted) return;
                              } catch (_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.cannotPlayAyah),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              _playingAyah == verse.ayahNumber
                                  ? Icons.stop_circle_rounded
                                  : Icons.play_circle_fill_rounded,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: _HighlightedVerseText(
                                text: verse.text,
                                query: widget.initialSearchQuery,
                                enabled: isHighlighted,
                                fontScale: _focusFontScale,
                                lineHeight: _focusLineHeight,
                                sepiaEnabled: _focusSepia,
                              ),
                            ),
                          ),
                          Container(
                            width: 32.w,
                            height: 32.w,
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 8.h),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              '${verse.ayahNumber}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),

        if (!_focusMode) ...[
          // ── مقاطع الحفظ
          AppText(
            l10n.memorizationSegments,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          ...ranges.map(
            (range) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '${range.label} • ${l10n.rangeAyahs(range.fromAyah, range.toAyah)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: 8.h),
                    AppAnimatedProgress(value: range.progress),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // ── بطاقة الأصوات
          SurahAudioCard(surah: widget.surah),
          SizedBox(height: 8.h),

          // ── روابط التفسير
          SurahTafsirLinksCard(surah: widget.surah),
          SizedBox(height: 8.h),

          // ── التفسير والترجمة
          SurahTafsirPreviewCard(surah: widget.surah),
          SizedBox(height: 16.h),
        ] else
          SizedBox(height: 8.h),
      ],
    );
    return AppScaffold(
      appBar: _focusMode
          ? AppBar(
              title: Text(l10n.surahNamed(widget.surah.nameArabic)),
              actions: [
                IconButton(
                  tooltip: l10n.exitFocusMode,
                  onPressed: () => setState(() => _focusMode = false),
                  icon: const Icon(Icons.fullscreen_exit_rounded),
                ),
              ],
            )
          : AppBar(
              title: Text(l10n.surahNamed(widget.surah.nameArabic)),
              actions: [
                if (widget.initialAyahNumber != null)
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: Text(l10n.backToSearch),
                  ),
                IconButton(
                  tooltip: l10n.enterFocusMode,
                  onPressed: () => setState(() => _focusMode = true),
                  icon: const Icon(Icons.fullscreen_rounded),
                ),
                IconButton(
                  onPressed: () => context.read<QuranCubit>().toggleBookmark(
                    widget.surah.number,
                  ),
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isBookmarked
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _focusMode
          ? _FocusReadingToolbar(
              fontScale: _focusFontScale,
              lineHeight: _focusLineHeight,
              sepiaEnabled: _focusSepia,
              onFontScaleChanged: _setFocusFontScale,
              onLineHeightChanged: _setFocusLineHeight,
              onSepiaChanged: _setFocusSepia,
              onReset: _resetFocusPreferences,
              onApplyToAll: _applyCurrentReadingSettingsToAllSurahs,
            )
          : null,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        color: _focusMode ? focusBackgroundColor : Colors.transparent,
        child: bodyList,
      ),
    );
  }

  Future<void> _playWithFallback({
    required List<String> urls,
    required VoidCallback onSuccess,
  }) async {
    for (final url in urls) {
      try {
        await AppInjector.audioRepository.loadSource(source: url);
        await AppInjector.audioRepository.play();
        onSuccess();
        return;
      } catch (_) {
        continue;
      }
    }
    throw Exception('all_audio_urls_failed');
  }

  List<QuranVerse> _buildFallbackVerses() {
    final verses = <QuranVerse>[];
    for (var ayah = 1; ayah <= widget.surah.verseCount; ayah++) {
      try {
        final text = quran_pkg.getVerse(
          widget.surah.number,
          ayah,
          verseEndSymbol: true,
        );
        verses.add(QuranVerse(ayahNumber: ayah, text: text));
      } catch (_) {
        // Ignore broken entries and keep the rest visible.
      }
    }
    return verses;
  }

  void _maybeJumpToInitialAyah(List<QuranVerse> verses) {
    if (_didJumpToInitialAyah) return;
    final targetAyah = widget.initialAyahNumber;
    if (targetAyah == null) return;
    final exists = verses.any((v) => v.ayahNumber == targetAyah);
    if (!exists) return;
    final key = _keyForAyah(targetAyah);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final context = key.currentContext;
      if (!mounted || context == null) return;
      _didJumpToInitialAyah = true;
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: widget.centerInitialAyah ? 0.5 : 0.08,
      );
      if (!mounted) return;
      setState(() => _highlightedAyah = targetAyah);
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _highlightedAyah = null);
      });
    });
  }

  GlobalKey _keyForAyah(int ayahNumber) {
    return _ayahKeys.putIfAbsent(
      ayahNumber,
      () => GlobalKey(debugLabel: 'ayah_$ayahNumber'),
    );
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _focusPrefsDebounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFocusPreferences() async {
    final prefs = AppInjector.appPreferences;
    _useUnifiedReadingPrefs =
        (await prefs.getString(_unifiedReadingPrefsKey) ?? '0') == '1';
    final savedScaleRaw = await prefs.getString(_effectiveKey(_focusFontScaleKey)) ??
        await prefs.getString(_focusFontScaleKey);
    final savedLineHeightRaw = await prefs.getString(
          _effectiveKey(_focusLineHeightKey),
        ) ??
        await prefs.getString(_focusLineHeightKey);
    final savedSepiaRaw = await prefs.getString(_effectiveKey(_focusSepiaKey)) ??
        await prefs.getString(_focusSepiaKey);

    final savedScale = double.tryParse(savedScaleRaw ?? '');
    final savedLineHeight = double.tryParse(savedLineHeightRaw ?? '');
    final savedSepia = savedSepiaRaw == '1';

    if (!mounted) return;
    setState(() {
      _focusFontScale =
          (savedScale ?? _defaultFocusFontScale).clamp(0.85, 1.35);
      _focusLineHeight =
          (savedLineHeight ?? _defaultFocusLineHeight).clamp(1.5, 2.5);
      _focusSepia = savedSepiaRaw == null ? _defaultFocusSepia : savedSepia;
    });
  }

  void _setFocusFontScale(double value) {
    setState(() => _focusFontScale = value);
    _schedulePersistFocusPreferences();
  }

  void _setFocusLineHeight(double value) {
    setState(() => _focusLineHeight = value);
    _schedulePersistFocusPreferences();
  }

  void _setFocusSepia(bool value) {
    setState(() => _focusSepia = value);
    _schedulePersistFocusPreferences();
  }

  void _schedulePersistFocusPreferences() {
    _focusPrefsDebounce?.cancel();
    _focusPrefsDebounce = Timer(const Duration(milliseconds: 250), () async {
      final prefs = AppInjector.appPreferences;
      await prefs.setString(
        _effectiveKey(_focusFontScaleKey),
        _focusFontScale.toStringAsFixed(3),
      );
      await prefs.setString(
        _effectiveKey(_focusLineHeightKey),
        _focusLineHeight.toStringAsFixed(3),
      );
      await prefs.setString(
        _effectiveKey(_focusSepiaKey),
        _focusSepia ? '1' : '0',
      );
    });
  }

  void _resetFocusPreferences() {
    setState(() {
      _focusFontScale = _defaultFocusFontScale;
      _focusLineHeight = _defaultFocusLineHeight;
      _focusSepia = _defaultFocusSepia;
    });
    _schedulePersistFocusPreferences();
  }

  Future<void> _applyCurrentReadingSettingsToAllSurahs() async {
    final prefs = AppInjector.appPreferences;
    final font = _focusFontScale.toStringAsFixed(3);
    final line = _focusLineHeight.toStringAsFixed(3);
    final sepia = _focusSepia ? '1' : '0';

    await prefs.setString(_focusFontScaleKey, font);
    await prefs.setString(_focusLineHeightKey, line);
    await prefs.setString(_focusSepiaKey, sepia);

    for (var surah = 1; surah <= 114; surah++) {
      await prefs.setString('${_focusFontScaleKey}_surah_$surah', font);
      await prefs.setString('${_focusLineHeightKey}_surah_$surah', line);
      await prefs.setString('${_focusSepiaKey}_surah_$surah', sepia);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.appliedReadingSettingsToAllSurahs)),
    );
  }

  String _effectiveKey(String baseKey) =>
      _useUnifiedReadingPrefs ? baseKey : _perSurahKey(baseKey);

  String _perSurahKey(String baseKey) => '${baseKey}_surah_${widget.surah.number}';
}

class _HighlightedVerseText extends StatelessWidget {
  const _HighlightedVerseText({
    required this.text,
    required this.query,
    required this.enabled,
    required this.fontScale,
    required this.lineHeight,
    required this.sepiaEnabled,
  });

  final String text;
  final String? query;
  final bool enabled;
  final double fontScale;
  final double lineHeight;
  final bool sepiaEnabled;

  @override
  Widget build(BuildContext context) {
    final baseFontSize = Theme.of(context).textTheme.titleMedium?.fontSize ?? 20;
    final baseStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          height: lineHeight,
          fontSize: baseFontSize * fontScale,
          color: sepiaEnabled ? const Color(0xFF4E342E) : null,
        );
    final rawQuery = query?.trim() ?? '';
    if (!enabled || rawQuery.isEmpty) {
      return AppText(text, style: baseStyle);
    }

    final normalizedQuery = ArabicTextNormalizer.normalize(rawQuery);
    if (normalizedQuery.isEmpty) {
      return AppText(text, style: baseStyle);
    }

    final tokens = text.split(RegExp(r'\s+'));
    final spans = <InlineSpan>[];
    final highlightStyle = baseStyle?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w800,
    );

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final normalizedToken = ArabicTextNormalizer.normalize(token);
      final isMatch = normalizedToken.contains(normalizedQuery);
      spans.add(
        TextSpan(
          text: token,
          style: isMatch ? highlightStyle : baseStyle,
        ),
      );
      if (i != tokens.length - 1) {
        spans.add(TextSpan(text: ' ', style: baseStyle));
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
    );
  }
}

class _FocusReadingToolbar extends StatelessWidget {
  const _FocusReadingToolbar({
    required this.fontScale,
    required this.lineHeight,
    required this.sepiaEnabled,
    required this.onFontScaleChanged,
    required this.onLineHeightChanged,
    required this.onSepiaChanged,
    required this.onReset,
    required this.onApplyToAll,
  });

  final double fontScale;
  final double lineHeight;
  final bool sepiaEnabled;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<double> onLineHeightChanged;
  final ValueChanged<bool> onSepiaChanged;
  final VoidCallback onReset;
  final VoidCallback onApplyToAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.format_size_rounded, size: 18),
                SizedBox(width: 6.w),
                Expanded(child: AppText(l10n.focusFontSize)),
                SizedBox(
                  width: 160.w,
                  child: Slider(
                    value: fontScale,
                    min: 0.85,
                    max: 1.35,
                    divisions: 10,
                    onChanged: onFontScaleChanged,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.format_line_spacing_rounded, size: 18),
                SizedBox(width: 6.w),
                Expanded(child: AppText(l10n.focusLineSpacing)),
                SizedBox(
                  width: 160.w,
                  child: Slider(
                    value: lineHeight,
                    min: 1.5,
                    max: 2.5,
                    divisions: 10,
                    onChanged: onLineHeightChanged,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 18),
                SizedBox(width: 6.w),
                Expanded(child: AppText(l10n.sepiaMode)),
                Switch(value: sepiaEnabled, onChanged: onSepiaChanged),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8.w,
                children: [
                  TextButton.icon(
                    onPressed: onReset,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.resetReadingSettings),
                  ),
                  TextButton.icon(
                    onPressed: onApplyToAll,
                    icon: const Icon(Icons.copy_all_rounded),
                    label: Text(l10n.applyReadingSettingsToAllSurahs),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
