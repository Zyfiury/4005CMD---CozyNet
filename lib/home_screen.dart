import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/mqtt_service.dart';
import 'temperature_control.dart';
import 'lamp_control_screen.dart';
import 'curtain_control_screen.dart';
import 'coffee_control_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkTheme;
  final String houseName;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkTheme,
    required this.houseName,
    required this.onLogout,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, bool> buttonStates = {
    "LIGHTING": false,
    "TEMP": false,
    "DOORBELL": false,
    "TV": false,
    "COFFEE": false,
    "CURTAINS": false,
  };

  Color lightingColor = Colors.white;
  double lightingBrightness = 100.0;

  @override
  void initState() {
    super.initState();
    final mqtt = Provider.of<MQTTService>(context, listen: false);
    mqtt.connect();
  }

  void _toggleDevice(String device) {
    setState(() => buttonStates[device] = !buttonStates[device]!);
    final mqtt = Provider.of<MQTTService>(context, listen: false);
    mqtt.sendMessage(device.toLowerCase(), buttonStates[device]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home - ${widget.houseName}'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.onToggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children:
              buttonStates.keys.map((label) {
                return DeviceCard(
                  label: label,
                  icon: _getIcon(
                    label,
                    label == "LIGHTING"
                        ? lightingColor.withOpacity(
                          (lightingBrightness.clamp(10, 100)) / 100,
                        )
                        : null,
                  ),
                  isActive: buttonStates[label]!,
                  brightness: label == "LIGHTING" ? lightingBrightness : null,
                  onTap: () {
                    if (label == "TEMP") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TemperatureControlScreen(),
                        ),
                      );
                    } else if (label == "LIGHTING") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LampControlScreen(),
                        ),
                      ).then((result) {
                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            lightingColor = result['color'] ?? Colors.white;
                            lightingBrightness = result['brightness'] ?? 100.0;
                          });
                        }
                      });
                    } else if (label == "CURTAINS") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CurtainControlScreen(),
                        ),
                      );
                    } else if (label == "COFFEE") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoffeeControlScreen(),
                        ),
                      );
                    } else {
                      _toggleDevice(label);
                    }
                  },
                );
              }).toList(),
        ),
      ),
    );
  }

  Icon _getIcon(String label, [Color? overrideColor]) {
    Color color =
        overrideColor ??
        (buttonStates[label]! ? Colors.white : Colors.grey[300]!);
    IconData iconData;
    switch (label) {
      case "LIGHTING":
        iconData = LucideIcons.lightbulb;
        break;
      case "TEMP":
        iconData = LucideIcons.thermometer;
        break;
      case "DOORBELL":
        iconData = LucideIcons.bell;
        break;
      case "TV":
        iconData = LucideIcons.monitor;
        break;
      case "COFFEE":
        iconData = LucideIcons.coffee;
        break;
      case "CURTAINS":
        iconData = LucideIcons.blinds;
        break;
      default:
        iconData = Icons.error;
    }
    return Icon(iconData, size: 40, color: color);
  }
}

class DeviceCard extends StatelessWidget {
  final String label;
  final Icon icon;
  final bool isActive;
  final VoidCallback onTap;
  final double? brightness;

  const DeviceCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent : Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey[300],
                  ),
                ),
                if (label == "TEMP")
                  Consumer<MQTTService>(
                    builder:
                        (context, mqtt, _) => Text(
                          '${mqtt.currentTemp.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                  ),
                if (label == "LIGHTING" && brightness != null)
                  Text(
                    'Brightness: ${brightness!.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
