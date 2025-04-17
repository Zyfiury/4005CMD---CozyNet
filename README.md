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
## Installation & Setup

### 1. Install Flutter Dependencies
```bash
flutter pub get
```

### 2. Launch the App
```bash
flutter run
```

---

## Configuration

### MQTT Broker
Open `lib/services/mqtt_service.dart` and update the `broker` constant to point at your MQTT server (default: `mqtt.eclipseprojects.io`).

### Database Settings
In `lib/services/database_helper.dart`, modify the `_databaseName` and `_databaseVersion` constants to suit your needs.

### Assets
Place Lottie animations, icons, and other static resources in the `assets/` directory, then register them under the `flutter.assets` section of `pubspec.yaml`.

---

## Usage Examples

- **Toggle a Lamp**
  ```bash
  mosquitto_pub -h your-broker -t devices/lamp/1/command -m '{"state": true}'
  ```

- **View Temperature History**  
  In the app dashboard, tap the **History** icon on the temperature chart to load the last 50 readings.

- **Switch Theme**  
  Tap the theme‑toggle button in the AppBar to switch between light and dark modes.

---

## Testing

- **Unit Tests**  
  Add service tests under `test/services/`.

- **Widget Tests**  
  Add widget tests under `test/widgets/`.

- **Run All Tests**
  ```bash
  flutter test
  ```

---
## Demo

Watch the light bulb turn on and off through the app:

https://github.com/user-attachments/assets/3e13981f-66b6-4336-bc07-98a01abca004
---


## Customization & Extension

### Add New Devices
1. Create a new simulator class in `lib/simulations/`, following the existing pattern.  
2. Define new MQTT topics in `MQTTService`.  
3. Implement a UI tile in `lib/widgets/device_tile.dart`.

### Enhance Authentication
Replace the built‑in “house‑name” login flow with Firebase Auth, OAuth, or another provider.

### Remote Persistence
Swap local SQLite storage for a remote backend (REST API, Firestore, AWS Amplify, etc.).

---

## Troubleshooting

- **MQTT Connection Issues**  
  - Verify broker URL, port, and network accessibility.  
  - Confirm any required client credentials or certificates.

- **Database Corruption**  
  Delete the `temperature.db` file in your app’s data directory or reinstall the app to reset the local database.

---

## Contributing

1. **Fork** the repository.  
2. **Create a feature branch**  
   ```bash
   git checkout -b feature/your-feature-name
   ```  
3. **Commit your changes**  
   ```bash
   git commit -m "feat: short description of your work"
   ```  
4. **Push** to your fork  
   ```bash
   git push origin feature/your-feature-name
   ```  
5. **Open a Pull Request** on the main repository.  

Please adhere to the [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting) and include tests for all new features.

Please follow the Flutter Style Guide and include tests for new features.

