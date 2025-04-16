import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_helper.dart';
import 'services/mqtt_service.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';
import 'lamp_simulation.dart';
import 'coffee_simulation.dart';
import 'curtain_simulation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and connect the simulations.
  final lampSim = LampSimulator();
  await lampSim.connect();

  final coffeeSim = CoffeeSimulator();
  await coffeeSim.connect();

  final curtainSim = CurtainSimulator();
  await curtainSim.connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MQTTService()),
        Provider(create: (_) => DatabaseHelper()),
      ],
      child: const SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends StatefulWidget {
  const SmartHomeApp({super.key});

  @override
  _SmartHomeAppState createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  bool isDarkTheme = true;
  bool isAuthenticated = false;
  String houseName = '';

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  void onAuthSuccess(String enteredHouseName) {
    setState(() {
      isAuthenticated = true;
      houseName = enteredHouseName;
    });
  }

  void onLogout() {
    setState(() {
      isAuthenticated = false;
      houseName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home:
          isAuthenticated
              ? HomeScreen(
                onToggleTheme: toggleTheme,
                isDarkTheme: isDarkTheme,
                houseName: houseName,
                onLogout: onLogout,
              )
              : WelcomeScreen(onAuthSuccess: onAuthSuccess),
    );
  }
}
