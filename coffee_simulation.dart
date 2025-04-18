import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class CoffeeSimulator {
  // MQTT broker settings.
  final String broker = 'mqtt.eclipseprojects.io';
  late MqttServerClient client;
  late String _clientId;
  Timer? _cycleTimer;
  Timer? _brewTimer;
  bool isBrewing = false;
  int countdown = 0; // Countdown in seconds

  /// Connects to the MQTT broker.
  Future<void> connect() async {
    _clientId = 'coffee-sim-${DateTime.now().millisecondsSinceEpoch}';
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
        print('CoffeeSimulator connected with client ID $_clientId');
        _startSimulation();
      } else {
        print('CoffeeSimulator connection failed: ${client.connectionStatus}');
        await _handleConnectionFailure();
      }
    } catch (e) {
      print('CoffeeSimulator connection error: $e');
      await _handleConnectionFailure();
    }
  }

  /// Handles connection failure by disconnecting and attempting to reconnect.
  Future<void> _handleConnectionFailure() async {
    client.disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }

  /// Starts the simulation.
  ///
  /// For this example, we start a new brew cycle every minute.
  /// In a real-world scenario, you might start the brew cycle based on a scheduled brew time.
  void _startSimulation() {
    // Check every minute if a brewing cycle should start.
    _cycleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!isBrewing) {
        _startBrewingCycle();
      }
    });
  }

  /// Starts a brewing cycle and publishes MQTT updates.
  void _startBrewingCycle() {
    isBrewing = true;
    countdown = 5 * 60; // Set brew time to 5 minutes.
    _publish('coffee/status', 'Brewing started');
    print('Brewing started. Countdown: $countdown seconds');

    _brewTimer?.cancel();
    _brewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        _publish('coffee/countdown', countdown.toString());
        countdown--;
      } else {
        timer.cancel();
        isBrewing = false;
        _publish('coffee/status', 'Coffee is ready');
        print('Coffee is ready!');
      }
    });
  }

  /// Publishes an MQTT message to the given topic.
  void _publish(String topic, String message) {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print('CoffeeSimulator not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  /// Disconnects from the MQTT broker and cancels any active timers.
  void disconnect() {
    _cycleTimer?.cancel();
    _brewTimer?.cancel();
    client.disconnect();
  }
}
