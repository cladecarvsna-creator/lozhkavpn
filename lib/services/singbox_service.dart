import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'singbox_config.dart';

enum SingboxStatus { stopped, starting, running, stopping }

class SingboxService {
  static const _channel = MethodChannel('com.lozhka/singbox');
  static final SingboxService _instance = SingboxService._();
  factory SingboxService() => _instance;
  SingboxService._() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  final _statusController = StreamController<SingboxStatus>.broadcast();
  Stream<SingboxStatus> get statusStream => _statusController.stream;
  SingboxStatus _status = SingboxStatus.stopped;
  SingboxStatus get status => _status;

  Future<void> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onStatusChanged':
        final s = call.arguments as String;
        switch (s) {
          case 'running': _setStatus(SingboxStatus.running);
          case 'stopped': _setStatus(SingboxStatus.stopped);
          case 'starting': _setStatus(SingboxStatus.starting);
        }
    }
  }

  void _setStatus(SingboxStatus s) {
    _status = s;
    _statusController.add(s);
  }

  Future<void> start({
    required String serverAddress,
    required int serverPort,
    required String uuid,
    required String publicKey,
    required String shortId,
    String serverName = '',
  }) async {
    if (_status == SingboxStatus.running || _status == SingboxStatus.starting) return;

    _setStatus(SingboxStatus.starting);

    final config = SingboxConfig.generate(
      serverAddress: serverAddress,
      serverPort: serverPort,
      uuid: uuid,
      publicKey: publicKey,
      shortId: shortId,
      serverName: serverName,
    );

    try {
      if (Platform.isWindows) {
        await _startWindows(config);
      } else {
        await _channel.invokeMethod('start', {'config': config});
      }
    } catch (e) {
      _setStatus(SingboxStatus.stopped);
      rethrow;
    }
  }

  Future<void> stop() async {
    if (_status == SingboxStatus.stopped) return;
    _setStatus(SingboxStatus.stopping);

    try {
      if (Platform.isWindows) {
        await _stopWindows();
      } else {
        await _channel.invokeMethod('stop');
      }
    } catch (e) {
      _setStatus(SingboxStatus.stopped);
      rethrow;
    }
  }

  // --- Windows: run sing-box.exe as subprocess ---
  Process? _winProcess;

  Future<void> _startWindows(String config) async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final singboxPath = '$exeDir/sing-box.exe';
    final configPath = '$exeDir/config.json';

    await File(configPath).writeAsString(config);

    _winProcess = await Process.start(
      singboxPath,
      ['run', '-c', configPath],
      mode: ProcessStartMode.detached,
    );

    _winProcess!.stdout.transform(utf8.decoder).listen((line) {
      if (line.contains('started')) {
        _setStatus(SingboxStatus.running);
      }
    });

    _winProcess!.stderr.transform(utf8.decoder).listen((line) {
      debugPrint('[sing-box] $line');
    });

    // give it a moment to start
    await Future.delayed(const Duration(seconds: 2));
    if (_status == SingboxStatus.starting) {
      _setStatus(SingboxStatus.running);
    }
  }

  Future<void> _stopWindows() async {
    _winProcess?.kill();
    _winProcess = null;

    // also kill any orphaned sing-box processes
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/f', '/im', 'sing-box.exe']);
    }

    _setStatus(SingboxStatus.stopped);
  }

  void dispose() {
    _statusController.close();
    _winProcess?.kill();
  }
}
