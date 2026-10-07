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

  const HomeScreen({super.key, required this.onOpenServers});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<cs.ConnectionState>();
    final connected = state.status == cs.TunnelStatus.connected;
    final connecting = state.status == cs.TunnelStatus.connecting;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusIndicator(online: connected),
                const SizedBox(width: 8),
                Text(
                  connected ? 'подключено' : (connecting ? 'подключение...' : 'отключено'),
                  style: LozhkaTheme.pixelStyle(
                    size: 16,
                    color: isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // timer
            Text(
              state.elapsedFormatted,
              style: LozhkaTheme.pixelStyle(
                size: 28,
                color: connected ? LozhkaColors.grass : (isDark ? LozhkaColors.steelDark : LozhkaColors.steel),
              ),
            ),
            const SizedBox(height: 24),

            // big round button
            ConnectButton(
              connected: connected,
              connecting: connecting,
              onTap: () => state.toggleConnection(),
            ),
            const SizedBox(height: 24),

            // server info
            GestureDetector(
              onTap: onOpenServers,
              child: PixelBlock(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('сервер', style: LozhkaTheme.pixelStyle(size: 14, color: isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2)),
                    Text(
                      '${state.currentServer.flag} ${state.currentServer.name}',
                      style: LozhkaTheme.bodyStyle(size: 14, color: isDark ? LozhkaColors.inkDark : LozhkaColors.ink),
                    ),
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
                  Text('протокол', style: LozhkaTheme.pixelStyle(size: 14, color: isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2)),
                  Text('vless / reality', style: LozhkaTheme.bodyStyle(size: 14, color: isDark ? LozhkaColors.inkDark : LozhkaColors.ink)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            PixelBlock(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('пинг', style: LozhkaTheme.pixelStyle(size: 14, color: isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2)),
                  Text(
                    connected ? '${state.currentServer.ping} ms' : '—',
                    style: LozhkaTheme.bodyStyle(size: 14, color: isDark ? LozhkaColors.inkDark : LozhkaColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            HeartsBar(filled: connected ? 5 : 3),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
