//Adams commit
import 'package:flutter/material.dart';

class LampControlScreen extends StatefulWidget {
  const LampControlScreen({super.key});

  @override
  State<LampControlScreen> createState() => _LampControlScreenState();
}

class _LampControlScreenState extends State<LampControlScreen> {
  bool isPowerOn = true;
  double brightness = 6.0;
  int selectedPreset = 0;
  bool isColorMode = true;

  final List<Color> presets = [
    Colors.white,
    const Color(0xFFEAC38F),
    Colors.blue,
    Colors.red,
    Colors.lightGreenAccent,
    Colors.purple,
    Colors.yellow,
  ];

  final List<Color> gradientColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop({
                    'color': presets[selectedPreset],
                    'brightness': brightness,
                    'brightnessLabel': '${brightness.toInt()}%',
                  });
                },
              ),
            ),

            // Lamp Icon and Location
            Column(
              children: [
                Icon(
                  Icons.light,
                  size: 100,
                  color: isPowerOn
                      ? presets[selectedPreset]
                          .withOpacity((brightness.clamp(10, 100)) / 100)
                      : Colors.grey[700],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lamp',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const Text(
                  'Bedroom',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Power Button
            Center(
              child: GestureDetector(
                onTap: () => setState(() => isPowerOn = !isPowerOn),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: isPowerOn ? Colors.lightBlue : Colors.grey,
                  child: const Icon(Icons.power_settings_new, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // My Presets
            const Text('My Presets', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: presets.asMap().entries.map((entry) {
                final index = entry.key;
                final color = entry.value;
                return GestureDetector(
                  onTap: () => setState(() => selectedPreset = index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: selectedPreset == index
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // Brightness
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Brightness', style: TextStyle(color: Colors.white)),
                Text('${brightness.toInt()}%',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            Slider(
              value: brightness,
              onChanged: (val) => setState(() => brightness = val),
              min: 0,
              max: 100,
              activeColor: const Color(0xFFFFD479),
              inactiveColor: Colors.grey[800],
            ),

            const SizedBox(height: 10),

            // White / Color tabs
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isColorMode = false),
                  child: Text(
                    'White',
                    style: TextStyle(
                      color: isColorMode ? Colors.grey : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => setState(() => isColorMode = true),
                  child: Text(
                    'Color',
                    style: TextStyle(
                      color: isColorMode ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Interactive color gradient
            GestureDetector(
              onPanDown: (details) => _handleGradientTap(details.localPosition),
              onPanUpdate: (details) => _handleGradientTap(details.localPosition),
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: gradientColors),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Energy Usage
            const Text('Energy Usage', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),

            ToggleButtons(
              isSelected: const [true, false, false],
              borderColor: Colors.grey,
              selectedColor: Colors.white,
              fillColor: Colors.grey[800],
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Today'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Past 7 Days'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Past 30 Days'),
                ),
              ],
              onPressed: (_) {},
            ),

            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('5.8h', style: TextStyle(color: Colors.white)),
                Text('0.015kWh', style: TextStyle(color: Colors.white)),
                Text('0.333kWh', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleGradientTap(Offset position) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final width = renderBox.size.width - 32; // account for ListView padding
      final x = position.dx.clamp(0, width);
      final ratio = x / width;

      final index = (ratio * (gradientColors.length - 1)).floor();
      final newColor = gradientColors[index];

      setState(() {
        presets[selectedPreset] = newColor;
      });
    }
  }
}
