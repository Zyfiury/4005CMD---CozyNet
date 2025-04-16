import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class LampSimulator {
  // MQTT broker settings.
  final String broker = 'mqtt.eclipseprojects.io';
  late MqttServerClient client;
  late String _clientId;
  Timer? _timer;

  // Connects to the MQTT broker.
  Future<void> connect() async {
    // Generate a unique client id.
    _clientId = 'lamp-sim-${DateTime.now().millisecondsSinceEpoch}';
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
          'LampSimulator connected with client ID $_clientId to broker $broker',
        );
        // Start the brightness simulation based on time-of-day.
        _startSimulation();
      } else {
        print('Connection failed: ${client.connectionStatus}');
        await _handleConnectionFailure();
      }
    } catch (e) {
      print('Connection error: $e');
      await _handleConnectionFailure();
    }
  }

  // Handles connection failures by disconnecting and attempting to reconnect.
  Future<void> _handleConnectionFailure() async {
    client.disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }

  // Starts a periodic timer to update brightness.
  void _startSimulation() {
    // Update every 10 seconds (adjust as needed).
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      double brightness = _calculateBrightness();
      print('Calculated brightness: ${brightness.toStringAsFixed(1)}%');
      sendMessage('lamp/brightness', brightness.toStringAsFixed(1));
    });
  }

  // Computes brightness based on the current time of day.
  // The simulation uses a sine function to model ambient light such that:
  // - At midnight (0:00), outside is dark so the lamp brightness is high (maximum).
  // - At noon (12:00), outside is bright so the lamp brightness is low (minimum).
  // - The brightness adjusts smoothly throughout the day.
  double _calculateBrightness() {
    DateTime now = DateTime.now();
    double hourDecimal = now.hour + now.minute / 60.0;
    // Map the current hour [0, 24) to an angle [0, 2*pi].
    double angle = (hourDecimal / 24) * 2 * pi;
    // Shift the sine wave so that:
    // - At midnight (hour = 0), sin(angle + pi/2) = 1, yielding maximum brightness.
    // - At noon (hour = 12), sin(angle + pi/2) = -1, yielding minimum brightness.
    double factor =
        (sin(angle + (pi / 2)) + 1) /
        2; // Ranges from 0 (at noon) to 1 (at midnight).
    const double minBrightness =
        10.0; // Lamp brightness percentage when it's bright outside.
    const double maxBrightness =
        100.0; // Lamp brightness percentage when it's dark outside.
    double brightness =
        minBrightness + (maxBrightness - minBrightness) * factor;
    return brightness;
  }

  // Publishes an MQTT message to a given topic.
  void sendMessage(String topic, String message) {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print('Not connected to broker');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // Disconnects from the MQTT broker and cancels the simulation timer.
  void disconnect() {
    _timer?.cancel();
    client.disconnect();
  }
}
