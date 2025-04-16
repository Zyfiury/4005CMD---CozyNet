import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CurtainControlScreen extends StatefulWidget {
  const CurtainControlScreen({super.key});

  @override
  State<CurtainControlScreen> createState() => _CurtainControlScreenState();
}

class _CurtainControlScreenState extends State<CurtainControlScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  String curtainState = "Closed";

  final String curtainAnimationAsset = 'assets/curtain.json';

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  void _setCurtainState(String state) {
    if (state == curtainState) return;

    if (_lottieController.duration == null) return;

    final double totalDuration =
        _lottieController.duration!.inMilliseconds.toDouble();
    final double oneSecondFraction = 1000 / totalDuration;

    if (state == "Close") {
      _lottieController.animateTo(
        oneSecondFraction,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    } else if (state == "Open") {
      _lottieController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

    setState(() {
      curtainState = state;
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart curtain"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 20),

          // Lottie curtain animation from local asset
          SizedBox(
            height: 200,
            child: Lottie.asset(
              curtainAnimationAsset,
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration;
                _lottieController.value = 0.0;
              },
            ),
          ),

          const Spacer(),

          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildControlButton("Open", curtainState == "Open"),
                _buildControlButton("Close", curtainState == "Closed"),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Animation from LottieFiles.com',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, bool isActive) {
    return ElevatedButton(
      onPressed: () => _setCurtainState(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.blue,
        foregroundColor: isActive ? Colors.white : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}
