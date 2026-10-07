import 'package:flutter/material.dart';
import '../theme/lozhka_theme.dart';

class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool ghost;
  final bool fullWidth;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.ghost = false,
    this.fullWidth = false,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final bg = widget.ghost
        ? (isDark ? LozhkaColors.cardDark : LozhkaColors.card)
        : LozhkaColors.honey;
    final fg = widget.ghost
        ? (isDark ? LozhkaColors.inkDark : LozhkaColors.ink)
        : LozhkaColors.honeyInk;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: Duration.zero,
        transform: _pressed
            ? (Matrix4.identity()..translate(4.0, 4.0))
            : Matrix4.identity(),
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: lineColor, width: 3),
          boxShadow: _pressed
              ? []
              : [BoxShadow(color: lineColor, offset: const Offset(4, 4))],
        ),
        child: Text(
          widget.label.toLowerCase(),
          textAlign: TextAlign.center,
          style: LozhkaTheme.pixelStyle(size: 19, color: fg),
        ),
      ),
    );
  }
}
