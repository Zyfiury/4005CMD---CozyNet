import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService extends ChangeNotifier {
  final String broker = 'mqtt.eclipseprojects.io';
  late MqttClient client;
  late String _clientId;
  final Random _random = Random();

  double _currentTemp = 20.0;
  int _setpoint = 22;
  bool _heaterOn = false;
  bool _acOn = false;
  final StreamController<double> _tempController = StreamController.broadcast();

  double get currentTemp => _currentTemp;
  int get setpoint => _setpoint;
  bool get heaterOn => _heaterOn;
  bool get acOn => _acOn;
  Stream<double> get temperatureStream => _tempController.stream;

  Future<void> connect() async {
    _clientId = 'flc-${const Uuid().v4().substring(0, 8)}';
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
          'MQTT connected successfully with client ID $_clientId to broker $broker',
        );
        _subscribeToTopics();
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

  Future<void> _handleConnectionFailure() async {
    client.disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }

  void _subscribeToTopics() {
    const topics = [
      'home/temperature',
      'home/thermostat/setpoint',
      'home/hvac/heater',
      'home/hvac/ac',
    ];

    for (final topic in topics) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
    client.updates!.listen(_handleMessages);
  }

  void _handleMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    final message = messages[0].payload as MqttPublishMessage;
    final payload = String.fromCharCodes(message.payload.message);
    final topic = messages[0].topic;

    switch (topic) {
      case 'home/temperature':
        _currentTemp = double.parse(payload);
        _tempController.add(_currentTemp);
        break;
      case 'home/thermostat/setpoint':
        _setpoint = int.parse(payload);
        break;
      case 'home/hvac/heater':
        _heaterOn = payload == 'ON';
        break;
      case 'home/hvac/ac':
        _acOn = payload == 'ON';
        break;
    }
    notifyListeners();
  }

  void _startSimulation() {
    Timer.periodic(const Duration(seconds: 2), (_) {
      final trend = (setpoint - currentTemp) * 0.1;
      final variation = (_random.nextDouble() - 0.5) * 2;
      final heaterEffect = heaterOn ? 0.5 : 0;
      final acEffect = acOn ? -0.5 : 0;
      _currentTemp += variation + trend + heaterEffect + acEffect;
      _currentTemp = _currentTemp.clamp(10.0, 30.0);
      sendMessage('temperature', _currentTemp.toStringAsFixed(1));
    });
  }

  void sendMessage(String topic, dynamic message) {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print('Not connected to broker');
      return;
    }
    final payload =
        message is bool ? (message ? 'ON' : 'OFF') : message.toString();
    _publish('home/$topic', payload);
  }

  void _publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void updateSetpoint(int newValue) {
    _setpoint = newValue.clamp(16, 28);
    sendMessage('thermostat/setpoint', _setpoint);
    notifyListeners();
  }

  void toggleHVAC(String device, bool state) {
    if (device == 'heater') _heaterOn = state;
    if (device == 'ac') _acOn = state;
    sendMessage('hvac/$device', state);
    notifyListeners();
  }

  @override
  void dispose() {
    _tempController.close();
    client.disconnect();
    super.dispose();
  }
}
