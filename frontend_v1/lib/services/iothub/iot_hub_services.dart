import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:frontend_v1/pages/config.dart';
import 'package:frontend_v1/services/internet/internet_location_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SasToken {
  final String token;
  final int expiry;

  SasToken(this.token, this.expiry);
}

class IoTHubService {
  final String hostName = 'VS-MeterIOT.azure-devices.net';
  final String deviceId = Config.terminalId;
  final String sharedAccessKey = Config.iotHubSharedAccessKey;

  late MqttServerClient client;

  final InternetLocationService _locationService =
      InternetLocationService.instance;

  Timer? _telemetryTimer;
  Timer? _sasRefreshTimer;

  bool isConnected = false;
  bool _isConnecting = false;
  bool _isManualReconnect = false;
  bool _isSendingTelemetry = false;

  // The last valid location is kept as a fallback.
  InternetLocation? _lastKnownLocation;

  // ================= SAS TOKEN =================

  SasToken _generateSasToken() {
    final expiry =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;

    final resourceUri = Uri.encodeComponent(
      '$hostName/devices/$deviceId',
    );

    final toSign = '$resourceUri\n$expiry';
    final key = base64.decode(sharedAccessKey);

    final hmac = Hmac(sha256, key);
    final signature = base64.encode(
      hmac.convert(utf8.encode(toSign)).bytes,
    );

    final encodedSignature = Uri.encodeComponent(signature);

    final token =
        'SharedAccessSignature '
        'sr=$resourceUri&sig=$encodedSignature&se=$expiry';

    return SasToken(token, expiry);
  }

  // ================= CONNECT =================

  Future<void> connect() async {
    if (_isConnecting) {
      print('⚠️ IoT Hub connection is already in progress');
      return;
    }

    _isConnecting = true;

    try {
      print('🔌 Connecting to IoT Hub...');

      client = MqttServerClient(hostName, deviceId);

      client.port = 8883;
      client.secure = true;
      client.keepAlivePeriod = 60;
      client.setProtocolV311();
      client.logging(on: true);

      final sas = _generateSasToken();

      final username =
          '$hostName/$deviceId/?api-version=2021-04-12';

      client.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(deviceId)
          .authenticateAs(username, sas.token)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      client.onConnected = () {
        print('✅ Connected to Azure IoT Hub');

        isConnected = true;

        startSending();
      };

      client.onDisconnected = () {
        print('❌ Disconnected from IoT Hub');

        isConnected = false;

        _telemetryTimer?.cancel();

        if (!_isManualReconnect) {
          Future.delayed(const Duration(minutes: 5), () {
            if (!isConnected && !_isConnecting) {
              connect();
            }
          });
        }
      };

      final status = await client.connect();

      if (status?.state == MqttConnectionState.connected) {
        print('🎉 MQTT Connected');

        _scheduleSasRefresh(sas.expiry);
      } else {
        print(
          '❌ Connection failed: ${status?.state}',
        );

        client.disconnect();
      }
    } catch (e, stackTrace) {
      print('❌ Connection exception: $e');
      print('❌ Stack trace: $stackTrace');

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

    final now =
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Refresh five minutes before expiry.
    final refreshInSeconds = (expiry - now) - 300;
    final safeDelay = max(refreshInSeconds, 30);

    print('⏳ SAS refresh in $safeDelay seconds');

    _sasRefreshTimer = Timer(
      Duration(seconds: safeDelay),
      () async {
        print('🔄 Refreshing SAS token before expiry...');

        await reconnect();
      },
    );
  }

  Future<void> reconnect() async {
    if (_isConnecting) {
      return;
    }

    _isManualReconnect = true;

    print('🔁 Manual reconnect for SAS refresh');

    try {
      client.disconnect();
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 2));

    try {
      await connect();
    } finally {
      _isManualReconnect = false;
    }
  }

  // ================= TELEMETRY =================

  void startSending() {
    _telemetryTimer?.cancel();

    print('📡 Starting telemetry...');

    // // Send immediately after connecting.
    // unawaited(_sendTelemetry());

    _telemetryTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        unawaited(_sendTelemetry());
      },
    );
  }

  Future<void> _sendTelemetry() async {
    if (_isSendingTelemetry) {
      print(
        '⚠️ Previous telemetry operation is still running. '
        'Skipping this cycle.',
      );
      return;
    }

    _isSendingTelemetry = true;

    try {
      final state = client.connectionStatus?.state;

      print('📋 MQTT connection state: $state');
      print('📋 isConnected variable: $isConnected');

      if (!isConnected ||
          state != MqttConnectionState.connected) {
        print(
          '⚠️ Skipping telemetry because MQTT is not connected',
        );
        return;
      }

      final internetLocation =
          await _locationService.getLocation();

      if (internetLocation != null) {
        _lastKnownLocation = internetLocation;
      }

      final location =
          internetLocation ?? _lastKnownLocation;

      final data = <String, dynamic>{
        'terminal_ID': Config.terminalId,

        // Replace these values with the actual sensor readings later.
        'battery_health': 80,
        'door_status':
            Random().nextBool() ? 'open' : 'close',

        // Null means that no valid internet location has been
        // obtained yet.
        'latitude': location?.latitude,
        'longitude': location?.longitude,

        // Extra location information.
        'location_city': location?.city,
        'location_region': location?.region,
        'location_country': location?.country,
        'location_isp': location?.isp,
        'public_ip': location?.ipAddress,
        'location_source':
            location?.source ?? 'unavailable',

        // Important: IP location is approximate, not GPS.
        'location_accuracy': 'approximate_ip',

        'datetime':
            DateTime.now().toUtc().toIso8601String(),
      };

      final builder = MqttClientPayloadBuilder();

      builder.addString(jsonEncode(data));

      final topic =
          'devices/$deviceId/messages/events/';

      final payload = builder.payload;

      if (payload == null) {
        print('❌ MQTT telemetry payload is empty');
        return;
      }

      // Check the connection again because the HTTP location request
      // may have taken several seconds.
      final latestState =
          client.connectionStatus?.state;

      if (!isConnected ||
          latestState != MqttConnectionState.connected) {
        print(
          '⚠️ MQTT disconnected while obtaining location. '
          'Telemetry was not published.',
        );
        return;
      }

      final messageId = client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        payload,
      );

      print('📡 Telemetry published');
      print('📡 MQTT message ID: $messageId');
      print('📡 Topic: $topic');
      print('📡 Data: ${jsonEncode(data)}');
    } catch (e, stackTrace) {
      print('❌ Telemetry send exception: $e');
      print('❌ Stack trace: $stackTrace');
    } finally {
      _isSendingTelemetry = false;
    }
  }

  // Manually refresh the location when required.
  Future<void> refreshLocation() async {
    print('🔄 Manually refreshing internet location...');

    final location = await _locationService.getLocation(
      forceRefresh: true,
    );

    if (location != null) {
      _lastKnownLocation = location;

      print(
        '✅ Location refreshed: '
        '${location.latitude}, ${location.longitude}',
      );
    } else {
      print('❌ Location refresh failed');
    }
  }

  // ================= STOP =================

  void stop() {
    print('🛑 Stopping IoT service...');

    _telemetryTimer?.cancel();
    _sasRefreshTimer?.cancel();

    isConnected = false;

    try {
      client.disconnect();
    } catch (_) {}
  }
}