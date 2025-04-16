import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CoffeeControlScreen extends StatefulWidget {
  const CoffeeControlScreen({super.key});

  @override
  State<CoffeeControlScreen> createState() => _CoffeeControlScreenState();
}

class _CoffeeControlScreenState extends State<CoffeeControlScreen> {
  bool isBrewing = false;
  TimeOfDay? selectedTime;
  String? autoBrewTime;
  Timer? _timer;
  Timer? _brewTimer;
  int countdown = 0; // Countdown in seconds

  final List<String> brewTimes = [
    "6:00 AM",
    "7:00 AM",
    "8:00 AM",
    "9:00 AM",
    "10:00 AM"
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _brewTimer?.cancel();
    super.dispose();
  }

  /// Starts a periodic timer to check for auto-brew time
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (selectedTime == null || isBrewing) return;

      final now = TimeOfDay.now();
      if (now.hour == selectedTime!.hour && now.minute == selectedTime!.minute) {
        _startBrewing();
      }
    });
  }

  /// Starts brewing process with a 5-minute countdown
  void _startBrewing() {
    setState(() {
      isBrewing = true;
      countdown = 5 * 60; // 5 minutes in seconds
    });

    _brewTimer?.cancel();
    _brewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        timer.cancel();
        setState(() => isBrewing = false);
      }
    });
  }

  /// Stops brewing immediately
  void _stopBrewing() {
    setState(() {
      isBrewing = false;
      countdown = 0;
    });
    _brewTimer?.cancel();
  }

  /// Opens a time picker dialog to set brew time
  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  /// Formats countdown timer
  String _formatCountdown() {
    final minutes = (countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

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
                  Navigator.of(context).pop();
                },
              ),
            ),

            // Coffee Machine Icon
            Column(
              children: [
                Icon(
                  LucideIcons.coffee,
                  size: 100,
                  color: isBrewing ? Colors.brown : Colors.grey[700],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coffee Machine',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const Text(
                  'Kitchen',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Brewing Status
            Text(
              isBrewing ? "☕ Brewing coffee..." : "Machine is idle",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isBrewing ? Colors.white : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            // Countdown timer (only visible when brewing)
            if (isBrewing)
              Text(
                "Time Left: ${_formatCountdown()}",
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            // Brewing Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _startBrewing,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Start Brewing"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isBrewing ? _stopBrewing : null, // Only active if brewing
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text("Stop Brewing"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Time Selection
            const Text(
              'Set Brew Time:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime == null
                      ? "No time selected"
                      : "Scheduled Time: ${selectedTime!.format(context)}",
                  style: const TextStyle(color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context),
                  child: const Text("Pick Time"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Auto-Brew Selection (Dropdown)
            const Text(
              'Auto-Brew Time',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: autoBrewTime,
              dropdownColor: Colors.grey[900],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: brewTimes.map((String time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(
                    time,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  autoBrewTime = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
