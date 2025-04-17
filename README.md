# CozyNet

**CozyNet** is a cross‑platform Flutter smart‑home prototype that showcases real‑time control and monitoring of simulated IoT devices. It combines MQTT messaging, local SQLite persistence, and interactive charts to give developers a solid foundation for building full‑featured home‑automation apps.

---

## Table of Contents

1. [Overview](#overview)  
2. [Key Features](#key-features)  
3. [Architecture & Modules](#architecture--modules)  
4. [Getting Started](#getting-started)  
5. [Configuration](#configuration)  
6. [Project Structure](#project-structure)  
7. [Usage Examples](#usage-examples)  
8. [Testing](#testing)  
9. [Customization & Extension](#customization--extension)  
10. [Troubleshooting](#troubleshooting)  
11. [Contributing](#contributing)  
12. [License](#license)

---

## Overview

CozyNet demonstrates how to:

- **Publish/subscribe** to an MQTT broker for device commands & telemetry  
- **Store** time‑series sensor data locally with SQLite  
- **Visualize** live and historical data using smooth, animated line charts  
- **Manage** app state through the Provider pattern and ChangeNotifiers  
- **Authenticate** users with a simple house‑name login flow  
- **Switch** between light and dark themes on the fly  

Designed as an educational prototype, CozyNet can be used as a starting point for your own smart‑home, IoT or real‑time data Flutter applications.

---

## Key Features

- **MQTT Control & Simulation**  
  - Uses the `mqtt_client` package to connect, subscribe, and publish  
  - Topics structured under `devices/{deviceType}/{deviceId}/command`  
  - Built‑in simulators for:  
    - Lamps (`lamp_simulation.dart`)  
    - Curtains (`curtain_simulation.dart`)  
    - Coffee machine (`coffee_simulation.dart`)  
    - HVAC (heater & AC)  

- **Local Persistence**  
  - `sqflite`‑backed `DatabaseHelper` for temperature readings  
  - Stores timestamped values in `temperature.db`  
  - Streams updates via broadcast `StreamController<double>`  

- **Interactive Charts**  
  - Real‑time and historical line charts via `fl_chart`  
  - Smooth animations, pan & zoom support  
  - Customizable axis labels and grid lines  

- **State Management & Theming**  
  - Provider pattern for dependency injection  
  - `ChangeNotifier`–based services (MQTT, database)  
  - Light/dark theme toggle with persistent preference  

- **Modular Codebase**  
  - Clean separation of UI, services, and simulation logic  
  - Easily add new device types by extending the simulator interface  
  - Ready for extension with authentication, push notifications, etc.

---

## Architecture & Modules

![image](https://github.com/user-attachments/assets/9d38c344-7e0e-4f00-a41c-044e44df6732)




- **`services/`**: Core logic for messaging and storage.  
- **`simulations/`**: Mock IoT device behaviors; can be replaced by real hardware clients.  
- **`screens/`**: Composable UI pages.  
- **`widgets/`**: Reusable UI components.

---

## Getting Started

1. **Clone the repo**  
   ```bash
   git clone https://github.com/your-username/cozynet.git
   cd cozynet
Install Flutter dependencies

bash
Copy
Edit
flutter pub get
Run on your device or emulator

bash
Copy
Edit
flutter run
Configuration
MQTT Broker
Edit lib/services/mqtt_service.dart to point at your broker (default: mqtt.eclipseprojects.io).

Database Name & Version
Modify _databaseName and _databaseVersion in DatabaseHelper.

Assets
Lottie animations and icons in assets/; update pubspec.yaml to register new files.

Usage Examples
Toggle a Lamp
Send {"state": true} to topic devices/lamp/1/command.

View Temperature History
On the dashboard, tap the chart’s “History” icon to load the last 50 readings.

Switch Theme
Press the theme toggle button in the AppBar.

Testing
Unit Tests
Place tests for services under test/services/.

Widget Tests
Add UI tests under test/widgets/.

Run all tests with:

bash
Copy
Edit
flutter test
Customization & Extension
Add New Devices

Create a simulator class in simulations/ following the existing pattern.

Publish/subscribe on new MQTT topics.

Build a UI tile in widgets/device_tile.dart.

Enhance Auth
Replace the simple house‑name flow with Firebase Auth or OAuth.

Remote Persistence
Swap SQLite with a REST API or cloud database (FireStore, AWS Amplify).

Troubleshooting
MQTT Connection Fails

Verify broker URL and port.

Check network/firewall settings.

Database Corruption

Uninstall the app or delete temperature.db to reset.

Contributing
Fork the repository

Create a feature branch (git checkout -b feature/x)

Commit your changes (git commit -m "Add feature x")

Push to the branch (git push origin feature/x)

Open a Pull Request

Please follow the Flutter Style Guide and include tests for new features.

