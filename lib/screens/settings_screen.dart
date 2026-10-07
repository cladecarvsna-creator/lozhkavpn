import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_state.dart' as cs;
import '../theme/lozhka_theme.dart';
import '../widgets/pixel_block.dart';
import '../widgets/pixel_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<cs.ConnectionState>();
    final ink = isDark ? LozhkaColors.inkDark : LozhkaColors.ink;
    final ink2 = isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('настройки', style: LozhkaTheme.headingStyle(size: 22, color: ink)),
            const SizedBox(height: 16),

            Text('соединение', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
            const SizedBox(height: 10),
            _row('автоподключение', trailing: PixelToggle(value: state.autoConnect, onChanged: state.setAutoConnect)),
            const SizedBox(height: 10),
            _row('kill switch', trailing: PixelToggle(value: state.killSwitch, onChanged: state.setKillSwitch)),
            const SizedBox(height: 10),
            _row('протокол', value: 'vless / reality'),
            const SizedBox(height: 24),

            Text('аккаунт', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
            const SizedBox(height: 10),
            _row('план', value: 'годовой ♥♥♥♥♥'),
            const SizedBox(height: 10),
            _row('устройства', value: '2 / 3'),
            const SizedBox(height: 10),
            _row('подписка до', value: '27.10.2026'),
            const SizedBox(height: 24),

            Text('о приложении', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
            const SizedBox(height: 10),
            _row('версия', value: '1.0.0'),
            const SizedBox(height: 10),
            _row('sing-box', value: '1.9.0'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, {String? value, Widget? trailing}) {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return PixelBlock(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: LozhkaTheme.bodyStyle(size: 14, color: isDark ? LozhkaColors.inkDark : LozhkaColors.ink)),
            if (trailing != null) trailing,
            if (value != null) Text(value, style: LozhkaTheme.pixelStyle(size: 13, color: isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2)),
          ],
        ),
      );
    });
  }
}
