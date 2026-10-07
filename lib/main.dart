import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/connection_state.dart' as cs;
import 'theme/lozhka_theme.dart';
import 'screens/home_screen.dart';
import 'screens/servers_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => cs.ConnectionState(),
      child: const LozhkaApp(),
    ),
  );
}

class LozhkaApp extends StatelessWidget {
  const LozhkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ложка',
      debugShowCheckedModeBanner: false,
      theme: LozhkaTheme.light(),
      darkTheme: LozhkaTheme.dark(),
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? LozhkaColors.lineDark : LozhkaColors.line;
    final bg2 = isDark ? LozhkaColors.bg2Dark : LozhkaColors.bg2;
    final ink2 = isDark ? LozhkaColors.ink2Dark : LozhkaColors.ink2;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: LozhkaColors.grass,
                border: Border.all(color: lineColor, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Text('ложка', style: LozhkaTheme.pixelStyle(size: 22, color: isDark ? LozhkaColors.inkDark : LozhkaColors.ink)),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(onOpenServers: () => setState(() => _tab = 1)),
          const ServersScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bg2,
          border: Border(top: BorderSide(color: lineColor, width: 3)),
        ),
        child: Row(
          children: [
            _navItem(0, '🏠', 'дом', ink2, lineColor),
            _navItem(1, '🌍', 'серверы', ink2, lineColor),
            _navItem(2, '⚙', 'настройки', ink2, lineColor),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int idx, String icon, String label, Color ink2, Color lineColor) {
    final active = _tab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(
                label,
                style: LozhkaTheme.pixelStyle(
                  size: 13,
                  color: active ? LozhkaColors.honey : ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
