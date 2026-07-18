import 'package:flutter/material.dart';
import 'package:werdi/core/responsive/responsive_utils.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign = TextAlign.start,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign textAlign;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    final fallback = Theme.of(context).textTheme.bodyLarge;
    final baseSize = style?.fontSize ?? fallback?.fontSize ?? 16;
    final resolvedMaxLines = maxLines;
    final resolvedOverflow = overflow ??
        (resolvedMaxLines != null ? TextOverflow.ellipsis : TextOverflow.visible);

    return Text(
      data,
      style: (style ?? fallback)?.copyWith(
        fontSize: ResponsiveUtils.font(context, baseSize),
      ),
      maxLines: resolvedMaxLines,
      overflow: resolvedOverflow,
      softWrap: softWrap ?? resolvedMaxLines == null,
      textAlign: textAlign,
    );
  }
}
