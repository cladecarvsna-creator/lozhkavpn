import 'package:flutter/material.dart';
import '../theme/lozhka_theme.dart';

class HeartsBar extends StatelessWidget {
  final int filled;
  final int total;

  const HeartsBar({super.key, this.filled = 3, this.total = 5});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        return Text(
          '♥',
          style: LozhkaTheme.pixelStyle(
            size: 22,
            color: i < filled ? LozhkaColors.red : (isDark ? LozhkaColors.steelDark : LozhkaColors.steel),
          ),
        );
      }),
    );
  }
}
