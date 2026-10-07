import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_state.dart' as cs;
import '../theme/lozhka_theme.dart';
import '../widgets/connect_button.dart';
import '../widgets/hearts_bar.dart';
import '../widgets/pixel_block.dart';
import '../widgets/status_indicator.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenServers;
  final VoidCallback onOpenSettings;

  const HomeScreen({super.key, required this.onOpenServers, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<cs.ConnectionState>();
    final connected = state.status == cs.TunnelStatus.connected;
    final connecting = state.status == cs.TunnelStatus.connecting;
    final ink2 = isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2;
    final ink = isDark ? LozhkaColors.inkDark : LozhkaColors.ink;

    final noServers = state.servers.isEmpty;
    final server = state.currentServer;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusIndicator(online: connected),
                const SizedBox(width: 8),
                Text(
                  connected ? 'подключено' : (connecting ? 'подключение...' : 'отключено'),
                  style: LozhkaTheme.pixelStyle(size: 16, color: ink2),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              state.elapsedFormatted,
              style: LozhkaTheme.pixelStyle(
                size: 28,
                color: connected ? LozhkaColors.grass : (isDark ? LozhkaColors.steelDark : LozhkaColors.steel),
              ),
            ),
            const SizedBox(height: 24),

            if (noServers) ...[
              PixelBlock(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('нет серверов', style: LozhkaTheme.pixelStyle(size: 16, color: ink)),
                    const SizedBox(height: 8),
                    Text(
                      'добавь url подписки в настройках',
                      style: LozhkaTheme.pixelStyle(size: 13, color: ink2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onOpenSettings,
                      child: Text('→ настройки', style: LozhkaTheme.pixelStyle(size: 14, color: LozhkaColors.honey)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ConnectButton(
                connected: connected,
                connecting: connecting,
                onTap: () => state.toggleConnection(),
              ),
            ],

            const SizedBox(height: 24),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PixelBlock(
                  color: LozhkaColors.red.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(12),
                  child: Text(state.error!, style: LozhkaTheme.pixelStyle(size: 13, color: LozhkaColors.red)),
                ),
              ),

            if (server != null) ...[
              GestureDetector(
                onTap: onOpenServers,
                child: PixelBlock(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('сервер', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
                      Text('${server.flag} ${server.name}', style: LozhkaTheme.bodyStyle(size: 14, color: ink)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              PixelBlock(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('протокол', style: LozhkaTheme.pixelStyle(size: 14, color: ink2)),
                    Text(server.protocols.join(' / '), style: LozhkaTheme.bodyStyle(size: 14, color: ink)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            HeartsBar(filled: connected ? 5 : (noServers ? 1 : 3)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
