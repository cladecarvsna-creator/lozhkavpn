import 'dart:async';
import 'package:flutter/foundation.dart';
import 'singbox_service.dart';
import 'subscription_service.dart';

enum TunnelStatus { disconnected, connecting, connected, disconnecting }

class ConnectionState extends ChangeNotifier {
  final SingboxService _singbox = SingboxService();

  TunnelStatus _status = TunnelStatus.disconnected;
  int _selectedServer = 0;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _autoConnect = true;
  bool _killSwitch = false;
  String _subscriptionUrl = '';
  List<ServerConfig> _servers = [];
  String? _error;
  StreamSubscription? _statusSub;

  ConnectionState() {
    _statusSub = _singbox.statusStream.listen((s) {
      switch (s) {
        case SingboxStatus.running:
          _status = TunnelStatus.connected;
          _error = null;
          _startTimer();
        case SingboxStatus.stopped:
          _status = TunnelStatus.disconnected;
          _stopTimer();
        case SingboxStatus.starting:
          _status = TunnelStatus.connecting;
        case SingboxStatus.stopping:
          _status = TunnelStatus.disconnecting;
      }
      notifyListeners();
    });
  }

  TunnelStatus get status => _status;
  int get selectedServer => _selectedServer;
  ServerConfig? get currentServer => _servers.isNotEmpty && _selectedServer < _servers.length ? _servers[_selectedServer] : null;
  List<ServerConfig> get servers => _servers;
  Duration get elapsed => _elapsed;
  bool get autoConnect => _autoConnect;
  bool get killSwitch => _killSwitch;
  String get subscriptionUrl => _subscriptionUrl;
  String? get error => _error;

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

  Future<void> loadSubscription(String url) async {
    _subscriptionUrl = url;
    _error = null;
    notifyListeners();

    try {
      _servers = await SubscriptionService.fetchServers(url);
      if (_servers.isEmpty) {
        _error = 'серверы не найдены';
      }
      _selectedServer = 0;
    } catch (e) {
      _error = 'ошибка загрузки: $e';
    }
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (_status == TunnelStatus.connecting || _status == TunnelStatus.disconnecting) return;

    if (_status == TunnelStatus.connected) {
      await _disconnect();
      return;
    }

    await _connect();
  }

  Future<void> _connect() async {
    final server = currentServer;
    if (server == null) {
      _error = 'добавь подписку в настройках';
      notifyListeners();
      return;
    }

    _status = TunnelStatus.connecting;
    _error = null;
    notifyListeners();

    try {
      await _singbox.start(
        serverAddress: server.address,
        serverPort: server.port,
        uuid: server.uuid,
        publicKey: server.publicKey,
        shortId: server.shortId,
        serverName: server.sni,
      );
    } catch (e) {
      _status = TunnelStatus.disconnected;
      _error = 'ошибка: $e';
      notifyListeners();
    }
  }

  Future<void> _disconnect() async {
    _status = TunnelStatus.disconnecting;
    notifyListeners();

    try {
      await _singbox.stop();
    } catch (e) {
      _status = TunnelStatus.disconnected;
      notifyListeners();
    }
  }

  void _startTimer() {
    _elapsed = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsed = Duration.zero;
  }

  void setAutoConnect(bool v) { _autoConnect = v; notifyListeners(); }
  void setKillSwitch(bool v) { _killSwitch = v; notifyListeners(); }

  @override
  void dispose() {
    _timer?.cancel();
    _statusSub?.cancel();
    _singbox.dispose();
    super.dispose();
  }
}
