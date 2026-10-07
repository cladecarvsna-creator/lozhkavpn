import 'package:flutter/material.dart';
import '../theme/lozhka_theme.dart';

class StatusIndicator extends StatelessWidget {
  final bool online;

  const StatusIndicator({super.key, required this.online});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: online ? LozhkaColors.grass : LozhkaColors.red,
        border: Border.all(color: lineColor, width: 2),
      ),
    );
  }
}
