import 'dart:convert';
import 'server_model.dart';

class SingboxConfig {
  static String generate({
    required String serverAddress,
    required int serverPort,
    required String uuid,
    required String publicKey,
    required String shortId,
    String serverName = '',
    String flow = 'xtls-rprx-vision',
  }) {
    final config = {
      "log": {"level": "info", "timestamp": true},
      "dns": {
        "servers": [
          {
            "tag": "dns-remote",
            "address": "https://1.1.1.1/dns-query",
            "detour": "proxy"
          },
          {
            "tag": "dns-direct",
            "address": "https://77.88.8.8/dns-query",
            "detour": "direct"
          },
          {"tag": "dns-block", "address": "rcode://success"}
        ],
        "rules": [
          {"outbound": ["any"], "server": "dns-direct"},
          {"clash_mode": "Direct", "server": "dns-direct"},
          {"clash_mode": "Global", "server": "dns-remote"}
        ],
        "strategy": "prefer_ipv4"
      },
      "inbounds": [
        {
          "type": "tun",
          "tag": "tun-in",
          "interface_name": "lozhka",
          "inet4_address": "172.19.0.1/30",
          "inet6_address": "fdfe:dcba:9876::1/126",
          "mtu": 9000,
          "auto_route": true,
          "strict_route": true,
          "stack": "mixed",
          "sniff": true,
          "sniff_override_destination": true
        }
      ],
      "outbounds": [
        {
          "type": "vless",
          "tag": "proxy",
          "server": serverAddress,
          "server_port": serverPort,
          "uuid": uuid,
          "flow": flow,
          "tls": {
            "enabled": true,
            "server_name": serverName.isNotEmpty ? serverName : serverAddress,
            "utls": {"enabled": true, "fingerprint": "chrome"},
            "reality": {
              "enabled": true,
              "public_key": publicKey,
              "short_id": shortId
            }
          },
          "packet_encoding": "xudp"
        },
        {"type": "direct", "tag": "direct"},
        {"type": "block", "tag": "block"},
        {"type": "dns", "tag": "dns-out"}
      ],
      "route": {
        "rules": [
          {"protocol": "dns", "outbound": "dns-out"},
          {"ip_is_private": true, "outbound": "direct"},
          {
            "rule_set": ["geoip-ru", "geosite-ru"],
            "outbound": "direct"
          }
        ],
        "rule_set": [
          {
            "type": "remote",
            "tag": "geoip-ru",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs",
            "download_detour": "proxy"
          },
          {
            "type": "remote",
            "tag": "geosite-ru",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ru.srs",
            "download_detour": "proxy"
          }
        ],
        "auto_detect_interface": true,
        "final": "proxy"
      },
      "experimental": {
        "clash_api": {
          "external_controller": "127.0.0.1:9090",
          "store_selected": true
        }
      }
    };

    return const JsonEncoder.withIndent('  ').convert(config);
  }

  static String generateFromSubscription(Map<String, dynamic> serverData) {
    return generate(
      serverAddress: serverData['server'] ?? '',
      serverPort: serverData['port'] ?? 443,
      uuid: serverData['uuid'] ?? '',
      publicKey: serverData['public_key'] ?? '',
      shortId: serverData['short_id'] ?? '',
      serverName: serverData['sni'] ?? '',
      flow: serverData['flow'] ?? 'xtls-rprx-vision',
    );
  }
}
