import 'package:flutter/material.dart';
import '../theme/lozhka_theme.dart';

class PixelToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PixelToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final trackColor = value ? LozhkaColors.grass : (isDark ? LozhkaColors.steelDark : LozhkaColors.steel);
    final thumbColor = isDark ? LozhkaColors.cardDark : LozhkaColors.card;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: trackColor,
          border: Border.all(color: lineColor, width: 2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: thumbColor,
              border: Border.all(color: lineColor, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
