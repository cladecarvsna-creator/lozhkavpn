class ServerLocation {
  final String flag;
  final String name;
  final String country;
  final int ping;
  final List<String> protocols;

  const ServerLocation({
    required this.flag,
    required this.name,
    required this.country,
    required this.ping,
    this.protocols = const ['vless', 'tcp', 'reality'],
  });
}

const defaultServers = [
  ServerLocation(flag: '🌐', name: 'автовыбор', country: '', ping: 0, protocols: ['vless', 'tcp', 'reality', 'json']),
  ServerLocation(flag: '🇺🇸', name: 'сша', country: 'us', ping: 112),
  ServerLocation(flag: '🇩🇪', name: 'германия', country: 'de', ping: 34),
  ServerLocation(flag: '🇳🇱', name: 'нидерланды', country: 'nl', ping: 28),
  ServerLocation(flag: '🇫🇮', name: 'финляндия', country: 'fi', ping: 42),
  ServerLocation(flag: '🇬🇧', name: 'лондон', country: 'gb', ping: 38),
  ServerLocation(flag: '🇯🇵', name: 'токио', country: 'jp', ping: 178),
  ServerLocation(flag: '🇸🇬', name: 'сингапур', country: 'sg', ping: 195),
  ServerLocation(flag: '🇨🇦', name: 'торонто', country: 'ca', ping: 124),
  ServerLocation(flag: '🇦🇺', name: 'сидней', country: 'au', ping: 230),
];
