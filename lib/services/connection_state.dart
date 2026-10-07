import 'dart:async';
import 'package:flutter/foundation.dart';
import 'server_model.dart';

enum TunnelStatus { disconnected, connecting, connected }

class ConnectionState extends ChangeNotifier {
  TunnelStatus _status = TunnelStatus.disconnected;
  int _selectedServer = 0;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _autoConnect = true;
  bool _killSwitch = false;

  TunnelStatus get status => _status;
  int get selectedServer => _selectedServer;
  ServerLocation get currentServer => defaultServers[_selectedServer];
  Duration get elapsed => _elapsed;
  bool get autoConnect => _autoConnect;
  bool get killSwitch => _killSwitch;

  String get elapsedFormatted {
    final h = _elapsed.inHours.toString().padLeft(2, '0');
    final m = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void selectServer(int index) {
    _selectedServer = index;
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (_status == TunnelStatus.connecting) return;

    if (_status == TunnelStatus.connected) {
      _disconnect();
      return;
    }

    _status = TunnelStatus.connecting;
    notifyListeners();

    // sing-box start would go here
    await Future.delayed(const Duration(milliseconds: 1200));

    _status = TunnelStatus.connected;
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
    notifyListeners();
  }

  void _disconnect() {
    _timer?.cancel();
    _timer = null;
    _status = TunnelStatus.disconnected;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void setAutoConnect(bool v) { _autoConnect = v; notifyListeners(); }
  void setKillSwitch(bool v) { _killSwitch = v; notifyListeners(); }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
