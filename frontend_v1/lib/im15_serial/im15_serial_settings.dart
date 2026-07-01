class IM15SerialSettings {
  final String? explicitPort;
  final int baudRate;
  final int dataBits;
  final int stopBits;
  final int parity;
  final int readTimeoutMs;
  final int writeTimeoutMs;
  final int openTimeoutMs;

  IM15SerialSettings({
    this.explicitPort,
    this.baudRate = 1200,
    this.dataBits = 8,
    this.stopBits = 1,
    this.parity = 0,
    this.readTimeoutMs = 1000,
    this.writeTimeoutMs = 1000,
    this.openTimeoutMs = 300,
  });

  factory IM15SerialSettings.fromMap(Map<String, String> map) {
    int i(String? s, int d) => int.tryParse(s ?? '') ?? d;

    int stopBits(String s) {
      switch (s) {
        case '1.5':
          return 15; // ✅ FIXED
        case '2':
          return 2;
        default:
          return 1;
      }
    }

    int parity(String s) {
      switch (s.toUpperCase()) {
        case 'ODD':
          return 1;
        case 'EVEN':
          return 2;
        default:
          return 0;
      }
    }

    return IM15SerialSettings(
      explicitPort: map['im15.port'],
      baudRate: i(map['im15.baud'], 1200),
      dataBits: i(map['im15.databits'], 8),
      stopBits: stopBits(map['im15.stopbits'] ?? '1'),
      parity: parity(map['im15.parity'] ?? 'NONE'),
      readTimeoutMs: i(map['im15.readTimeoutMs'], 1000),
      writeTimeoutMs: i(map['im15.writeTimeoutMs'], 1000),
      openTimeoutMs: i(map['im15.openTimeoutMs'], 300),
    );
  }
}
