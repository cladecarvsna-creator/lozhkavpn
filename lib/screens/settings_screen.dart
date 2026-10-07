import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_state.dart' as cs;
import '../theme/lozhka_theme.dart';
import '../widgets/pixel_block.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<cs.ConnectionState>();
    _urlController.text = state.subscriptionUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscription() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _loading = true);
    final state = context.read<cs.ConnectionState>();
    await state.loadSubscription(url);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<cs.ConnectionState>();
    final ink = isDark ? LozhkaColors.inkDark : LozhkaColors.ink;
    final ink2 = isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final cardColor = isDark ? LozhkaColors.cardDark : LozhkaColors.card;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('настройки', style: LozhkaTheme.headingStyle(size: 22, color: ink)),
            const SizedBox(height: 16),

            // subscription
            Text('подписка', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
            const SizedBox(height: 10),
            PixelBlock(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('url подписки', style: LozhkaTheme.pixelStyle(size: 12, color: ink2)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: lineColor, width: 2),
                      color: isDark ? LozhkaColors.bgDark : LozhkaColors.bg,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _urlController,
                      style: LozhkaTheme.pixelStyle(size: 13, color: ink),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'https://...',
                        hintStyle: LozhkaTheme.pixelStyle(size: 13, color: isDark ? LozhkaColors.steelDark : LozhkaColors.steel),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PixelButton(
                    label: _loading ? 'загрузка...' : 'обновить серверы',
                    fullWidth: true,
                    onPressed: _loading ? () {} : _loadSubscription,
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 8),
                    Text(state.error!, style: LozhkaTheme.pixelStyle(size: 12, color: LozhkaColors.red)),
                  ],
                  if (state.servers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'загружено ${state.servers.length} серверов',
                      style: LozhkaTheme.pixelStyle(size: 12, color: LozhkaColors.grass),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // connection settings
            Text('соединение', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
            const SizedBox(height: 10),
            _row('автоподключение', trailing: PixelToggle(value: state.autoConnect, onChanged: state.setAutoConnect)),
            const SizedBox(height: 10),
            _row('kill switch', trailing: PixelToggle(value: state.killSwitch, onChanged: state.setKillSwitch)),
            const SizedBox(height: 24),

            Text('о приложении', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
            const SizedBox(height: 10),
            _row('версия', value: '1.0.0'),
            const SizedBox(height: 10),
            _row('ядро', value: 'sing-box'),
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
