import 'package:flutter/material.dart';
import '../theme/lozhka_theme.dart';

class PixelBlock extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double shadowOffset;
  final EdgeInsetsGeometry padding;

  const PixelBlock({
    super.key,
    required this.child,
    this.color,
    this.shadowOffset = 6,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final cardColor = color ?? (isDark ? LozhkaColors.cardDark : LozhkaColors.card);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: lineColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: lineColor,
            offset: Offset(shadowOffset, shadowOffset),
          ),
        ],
      ),
      child: child,
    );
  }
}
