import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../theme/lozhka_theme.dart';

class ConnectButton extends StatefulWidget {
  final bool connected;
  final bool connecting;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.connected,
    required this.connecting,
    required this.onTap,
  });

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final size = 180.0;

    Color bgColor;
    Color fgColor;
    String label;

    if (widget.connecting) {
      bgColor = LozhkaColors.honeyDk;
      fgColor = LozhkaColors.honeyInk;
      label = 'подключение...';
    } else if (widget.connected) {
      bgColor = LozhkaColors.honey;
      fgColor = LozhkaColors.honeyInk;
      label = 'отключить';
    } else {
      bgColor = isDark ? LozhkaColors.cardDark : LozhkaColors.card;
      fgColor = isDark ? LozhkaColors.inkDark : LozhkaColors.ink;
      label = 'подключить';
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.connecting) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        listenable: _pulseController,
        builder: (context, child) {
          final glowOpacity = widget.connected ? (_pulseController.value * 0.3 + 0.1) : 0.0;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: lineColor, width: 3),
              boxShadow: [
                if (!_pressed)
                  BoxShadow(color: lineColor, offset: const Offset(5, 5)),
                if (widget.connected)
                  BoxShadow(
                    color: LozhkaColors.honey.withValues(alpha: glowOpacity),
                    blurRadius: 0,
                    spreadRadius: 8,
                  ),
              ],
            ),
            transform: _pressed
                ? (Matrix4.identity()..translate(5.0, 5.0))
                : Matrix4.identity(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(48, 48),
                  painter: _SpoonPainter(
                    outlineColor: lineColor,
                    glowing: widget.connected,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: LozhkaTheme.pixelStyle(size: 16, color: fgColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}

class _SpoonPainter extends CustomPainter {
  final Color outlineColor;
  final bool glowing;

  _SpoonPainter({required this.outlineColor, required this.glowing});

  static const _spoon = [
    '...##.......',
    '..#ss#......',
    '.#sssh#.....',
    '#ssssh#.....',
    '#sssss#.....',
    '.#sss#......',
    '..###.......',
    '...#s#......',
    '....#s#.....',
    '.....#s#....',
    '......#s#...',
    '.......##...',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final px = size.width / 16;
    final paint = Paint();

    if (glowing) {
      paint.color = LozhkaColors.honey.withValues(alpha: 0.4);
      for (int r = 0; r < _spoon.length; r++) {
        for (int c = 0; c < _spoon[r].length; c++) {
          if (_spoon[r][c] != '.') {
            canvas.drawRect(Rect.fromLTWH((c + 2) * px - px, (r + 2) * px - px, px * 3, px * 3), paint);
          }
        }
      }
    }

    for (int r = 0; r < _spoon.length; r++) {
      for (int c = 0; c < _spoon[r].length; c++) {
        final ch = _spoon[r][c];
        if (ch == '.') continue;
        if (ch == '#') paint.color = outlineColor;
        else if (ch == 's') paint.color = const Color(0xFFC9D3DE);
        else if (ch == 'h') paint.color = Colors.white;
        canvas.drawRect(Rect.fromLTWH((c + 2) * px, (r + 2) * px, px, px), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpoonPainter old) =>
      old.glowing != glowing || old.outlineColor != outlineColor;
}
