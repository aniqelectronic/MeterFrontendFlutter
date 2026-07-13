import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SasToken {
  final String token;
  final int expiry;

  SasToken(this.token, this.expiry);
}

class IoTHubService {
  final String hostName = "VS-MeterIOT.azure-devices.net";
  final String deviceId = Config.terminalId;
  final String sharedAccessKey =
      Config.iotHubSharedAccessKey; // Replace with your IoT Hub device's shared access key

  late MqttServerClient client;

  Timer? _telemetryTimer;
  Timer? _sasRefreshTimer;

  bool isConnected = false;
  bool _isConnecting = false;
  bool _isManualReconnect = false;

  // ================= SAS TOKEN =================
  SasToken _generateSasToken() {
    final expiry =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;

    final resourceUri =
        Uri.encodeComponent("$hostName/devices/$deviceId");

    final toSign = "$resourceUri\n$expiry";
    final key = base64.decode(sharedAccessKey);

    final hmac = Hmac(sha256, key);
    final signature =
        base64.encode(hmac.convert(utf8.encode(toSign)).bytes);

    final encodedSig = Uri.encodeComponent(signature);

    final token =
        "SharedAccessSignature sr=$resourceUri&sig=$encodedSig&se=$expiry";

    return SasToken(token, expiry);
  }

  // ================= CONNECT =================
  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      print("🔌 Connecting to IoT Hub...");

      client = MqttServerClient(hostName, deviceId);

      client.port = 8883;
      client.secure = true;
      client.keepAlivePeriod = 60;
      client.setProtocolV311();
      client.logging(on: true);

      final sas = _generateSasToken();

      final username =
          "$hostName/$deviceId/?api-version=2021-04-12";

      client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(deviceId)
          .authenticateAs(username, sas.token)
          .startClean() // ✅ VERY IMPORTANT
          .withWillQos(MqttQos.atLeastOnce);

      // ================= CALLBACKS =================
      client.onConnected = () {
        print("✅ Connected to Azure IoT Hub");
        isConnected = true;

        startSending(); // restart telemetry
      };

      client.onDisconnected = () {
        print("❌ Disconnected from IoT Hub");
        isConnected = false;

        _telemetryTimer?.cancel();

        // Only reconnect if NOT manual
        if (!_isManualReconnect) {
          Future.delayed(const Duration(seconds: 5), () {
            connect();
          });
        }
      };

      final status = await client.connect();

      if (status?.state == MqttConnectionState.connected) {
        print("🎉 MQTT Connected");

        _scheduleSasRefresh(sas.expiry);
      } else {
        print("❌ Connection failed: ${status?.state}");
        client.disconnect();
      }
    } catch (e) {
      print("❌ Connection exception: $e");
      try {
        client.disconnect();
      } catch (_) {}
    } finally {
      _isConnecting = false;
    }
  }

  // ================= SAS REFRESH =================
  void _scheduleSasRefresh(int expiry) {
    _sasRefreshTimer?.cancel();

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // refresh 5 minutes before expiry
    final refreshInSeconds = (expiry - now) - 300;

    final safeDelay = max(refreshInSeconds, 30);

    print("⏳ SAS refresh in $safeDelay seconds");

    _sasRefreshTimer = Timer(Duration(seconds: safeDelay), () async {
      print("🔄 Refreshing SAS token BEFORE expiry...");
      await reconnect();
    });
  }

  Future<void> reconnect() async {
    _isManualReconnect = true;

    print("🔁 Manual reconnect (SAS refresh)");

    try {
      client.disconnect();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));

    await connect();

    _isManualReconnect = false;
  }

  // ================= TELEMETRY =================
  void startSending() {
    _telemetryTimer?.cancel();

    print("📡 Starting telemetry...");

    // Send immediately after connection.
    _sendTelemetry();

    _telemetryTimer =
        Timer.periodic(const Duration(seconds: 60), (_) {
      _sendTelemetry();
    });
  }

  void _sendTelemetry() {
    try {
      final state = client.connectionStatus?.state;

      print("📋 MQTT connection state: $state");
      print("📋 isConnected variable: $isConnected");

      if (!isConnected || state != MqttConnectionState.connected) {
        print("⚠️ Skipping telemetry because MQTT is not connected");
        return;
      }

      final data = {
        "terminal_ID": Config.terminalId,
        "battery_health": 80,
        "door_status": Random().nextBool() ? "open" : "close",
        "latitude": 3.1837,
        "longitude": 101.7686,
        "datetime": DateTime.now().toUtc().toIso8601String(),
      };

      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(data));

      final topic = "devices/$deviceId/messages/events/";

      final messageId = client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
      );

      print("📡 Telemetry published");
      print("📡 MQTT message ID: $messageId");
      print("📡 Topic: $topic");
      print("📡 Data: ${jsonEncode(data)}");
    } catch (e, stackTrace) {
      print("❌ Telemetry send exception: $e");
      print("❌ Stack trace: $stackTrace");
    }
  }

  // ================= STOP =================
  void stop() {
    print("🛑 Stopping IoT service...");

    _telemetryTimer?.cancel();
    _sasRefreshTimer?.cancel();

    try {
      client.disconnect();
    } catch (_) {}
  }
}