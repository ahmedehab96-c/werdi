import 'package:flutter/material.dart';
import 'package:werdi/core/extensions/context_extensions.dart';
import 'package:werdi/features/quran/domain/models/quran_filter.dart';

class QuranFilterChips extends StatelessWidget {
  const QuranFilterChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final QuranFilter selected;
  final ValueChanged<QuranFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: QuranFilter.values.map((filter) {
          final label = switch (filter) {
            QuranFilter.all => l10n.filterAll,
            QuranFilter.memorized => l10n.statusMemorized,
            QuranFilter.inProgress => l10n.statusInProgress,
            QuranFilter.review => l10n.filterReview,
          };
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected == filter,
              onSelected: (_) => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
