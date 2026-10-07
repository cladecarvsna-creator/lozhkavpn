import 'dart:convert';
import 'dart:io';

class ServerConfig {
  final String name;
  final String flag;
  final String address;
  final int port;
  final String uuid;
  final String publicKey;
  final String shortId;
  final String sni;
  final String flow;
  final List<String> protocols;

  const ServerConfig({
    required this.name,
    required this.flag,
    required this.address,
    required this.port,
    required this.uuid,
    required this.publicKey,
    required this.shortId,
    this.sni = '',
    this.flow = 'xtls-rprx-vision',
    this.protocols = const ['vless', 'tcp', 'reality'],
  });
}

class SubscriptionService {
  static Future<List<ServerConfig>> fetchServers(String subscriptionUrl) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(subscriptionUrl));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      // try base64 first (common subscription format)
      String decoded;
      try {
        decoded = utf8.decode(base64.decode(body.trim()));
      } catch (_) {
        decoded = body;
      }

      final lines = decoded.split('\n').where((l) => l.trim().isNotEmpty).toList();
      final servers = <ServerConfig>[];

      for (final line in lines) {
        final config = _parseVlessLink(line.trim());
        if (config != null) servers.add(config);
      }

      return servers;
    } finally {
      client.close();
    }
  }

  static ServerConfig? _parseVlessLink(String link) {
    if (!link.startsWith('vless://')) return null;

    try {
      final uri = Uri.parse(link);
      final uuid = uri.userInfo;
      final address = uri.host;
      final port = uri.port;
      final params = uri.queryParameters;
      final name = Uri.decodeComponent(uri.fragment);

      final flag = _guessFlag(name);

      return ServerConfig(
        name: name.toLowerCase(),
        flag: flag,
        address: address,
        port: port,
        uuid: uuid,
        publicKey: params['pbk'] ?? '',
        shortId: params['sid'] ?? '',
        sni: params['sni'] ?? '',
        flow: params['flow'] ?? 'xtls-rprx-vision',
        protocols: [
          'vless',
          params['type'] ?? 'tcp',
          if (params['security'] == 'reality') 'reality',
        ],
      );
    } catch (_) {
      return null;
    }
  }

  static String _guessFlag(String name) {
    final n = name.toLowerCase();
    if (n.contains('us') || n.contains('сша') || n.contains('america')) return '🇺🇸';
    if (n.contains('de') || n.contains('герман') || n.contains('germany') || n.contains('frankfurt')) return '🇩🇪';
    if (n.contains('nl') || n.contains('нидерланд') || n.contains('netherlands') || n.contains('amsterdam')) return '🇳🇱';
    if (n.contains('fi') || n.contains('финлянд') || n.contains('finland') || n.contains('helsinki')) return '🇫🇮';
    if (n.contains('gb') || n.contains('uk') || n.contains('лондон') || n.contains('london')) return '🇬🇧';
    if (n.contains('jp') || n.contains('токио') || n.contains('japan') || n.contains('tokyo')) return '🇯🇵';
    if (n.contains('sg') || n.contains('сингапур') || n.contains('singapore')) return '🇸🇬';
    if (n.contains('ca') || n.contains('канад') || n.contains('canada') || n.contains('toronto')) return '🇨🇦';
    if (n.contains('au') || n.contains('австрал') || n.contains('australia') || n.contains('sydney')) return '🇦🇺';
    if (n.contains('fr') || n.contains('франц') || n.contains('france') || n.contains('paris')) return '🇫🇷';
    if (n.contains('ru') || n.contains('росси') || n.contains('russia') || n.contains('moscow')) return '🇷🇺';
    return '🌐';
  }
}
