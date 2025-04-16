import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import 'screens/temperature_history.dart';

class TemperatureControlScreen extends StatelessWidget {
  const TemperatureControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MQTTService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Control'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TemperatureHistoryScreen(),
                  ),
                ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTemperatureDisplay(mqtt),
            const SizedBox(height: 20),
            _buildSetpointControl(mqtt),
            const SizedBox(height: 20),
            _buildHVACControls(mqtt),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureDisplay(MQTTService mqtt) {
    return Column(
      children: [
        StreamBuilder<double>(
          stream: mqtt.temperatureStream,
          builder: (context, snapshot) {
            double displayTemp = mqtt.currentTemp;
            if (snapshot.hasData) {
              displayTemp = snapshot.data!;
            }
            return Text(
              '${displayTemp.toStringAsFixed(1)}°C',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            );
          },
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (mqtt.currentTemp - 10) / 20, // for a 10–30°C range
          minHeight: 20,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(_getTempColor(mqtt.currentTemp)),
        ),
      ],
    );
  }

  Widget _buildSetpointControl(MQTTService mqtt) {
    return Column(
      children: [
        Slider(
          value: mqtt.setpoint.toDouble(),
          min: 16,
          max: 28,
          divisions: 12,
          label: '${mqtt.setpoint}°C',
          onChanged: (value) => mqtt.updateSetpoint(value.round()),
        ),
        const Text('Setpoint Temperature'),
      ],
    );
  }

  Widget _buildHVACControls(MQTTService mqtt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildHVACButton('Heater', mqtt.heaterOn, Icons.heat_pump, mqtt),
        _buildHVACButton('AC', mqtt.acOn, Icons.ac_unit, mqtt),
      ],
    );
  }

  Widget _buildHVACButton(
    String label,
    bool isActive,
    IconData icon,
    MQTTService mqtt,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(icon, size: 40),
          color: isActive ? Colors.orange : Colors.grey,
          onPressed: () => mqtt.toggleHVAC(label.toLowerCase(), !isActive),
        ),
        Text(label),
        Text(isActive ? 'ON' : 'OFF'),
      ],
    );
  }

  Color _getTempColor(double temp) {
    final clampedTemp = temp.clamp(10.0, 30.0).toDouble();
    final hue = (30 - clampedTemp) * 6;
    return HSVColor.fromAHSV(1.0, hue, 0.8, 0.9).toColor();
  }
}
