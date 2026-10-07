import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connection_state.dart' as cs;
import '../theme/lozhka_theme.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<cs.ConnectionState>();
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final ink = isDark ? LozhkaColors.inkDark : LozhkaColors.ink;
    final ink2 = isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2;
    final servers = state.servers;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text('серверы', style: LozhkaTheme.headingStyle(size: 22, color: ink)),
          ),
          if (servers.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'добавь подписку в настройках',
                  style: LozhkaTheme.pixelStyle(size: 14, color: ink2),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: servers.length,
                itemBuilder: (context, i) {
                  final s = servers[i];
                  final selected = i == state.selectedServer;

                  return GestureDetector(
                    onTap: () => state.selectServer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? LozhkaColors.honey : (isDark ? LozhkaColors.cardDark : LozhkaColors.card),
                        border: Border.all(color: lineColor, width: 3),
                        boxShadow: [BoxShadow(color: lineColor, offset: const Offset(4, 4))],
                      ),
                      child: Row(
                        children: [
                          Text(s.flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: LozhkaTheme.pixelStyle(
                                    size: 16,
                                    color: selected ? LozhkaColors.honeyInk : ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.protocols.join(' / '),
                                  style: LozhkaTheme.pixelStyle(
                                    size: 12,
                                    color: selected ? LozhkaColors.honeyInk.withValues(alpha: 0.7) : ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selected)
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                color: LozhkaColors.grass,
                                border: Border.all(color: selected ? LozhkaColors.honeyInk : lineColor, width: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
