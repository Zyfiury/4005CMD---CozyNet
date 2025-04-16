import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class CurtainSimulator {
  // MQTT broker settings.
  final String broker = 'mqtt.eclipseprojects.io';
  late MqttServerClient client;
  late String _clientId;
  Timer? _timer;

  // Current state of the curtain.
  String curtainState = 'Closed';

  /// Connects to the MQTT broker.
  Future<void> connect() async {
    _clientId = 'curtain-sim-${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient(broker, _clientId);
    client.port = 1883;
    client.setProtocolV311();
    client.keepAlivePeriod = 60;
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_clientId)
        .startClean()
        .keepAliveFor(60);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print(
          'CurtainSimulator connected with client ID $_clientId to broker $broker',
        );
        // Start simulation once connected.
        _startSimulation();
      } else {
        print('CurtainSimulator connection failed: ${client.connectionStatus}');
        await _handleConnectionFailure();
      }
    } catch (e) {
      print('CurtainSimulator connection error: $e');
      await _handleConnectionFailure();
    }
  }

  /// Handles connection failure by disconnecting and retrying.
  Future<void> _handleConnectionFailure() async {
    client.disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }

  /// Starts a periodic timer that checks the time of day
  /// to determine if the curtains should be open or closed.
  ///
  /// In this example:
  /// - Between 6:00 AM and 6:00 PM, curtains are set to "Open".
  /// - Otherwise, curtains are set to "Closed".
  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      DateTime now = DateTime.now();
      int hour = now.hour;
      String desiredState = (hour >= 6 && hour < 18) ? 'Open' : 'Closed';
      if (desiredState != curtainState) {
        curtainState = desiredState;
        _publish('curtains/status', curtainState);
        print('Curtain state changed to $curtainState at ${now.toString()}');
      }
    });
  }

  /// Publishes a message via MQTT.
  void _publish(String topic, String message) {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print('CurtainSimulator not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  /// Cancels active timers and disconnects from the MQTT broker.
  void disconnect() {
    _timer?.cancel();
    client.disconnect();
  }
}
