# 📱 HabeshaFreight — Mobile Application

![Platform](https://img.shields.io/badge/Platform-Flutter%20%7C%20Dart-02569B?logo=flutter&logoColor=white)
![Design System](https://img.shields.io/badge/Theme-Dark%20Nocturne%20Corridor-1A1A2E)
[![Demo Video](https://img.shields.io/badge/Demo%20Video-Awesome%20Screenshot-0080FF?logo=googlechrome&logoColor=white)](https://www.awesomescreenshot.com/video/57793490?key=44418869b6f6497f05378f28b54dbb83)

## Group Members
- 1, Masud Wubetu Hassen — CTC-6562-26
- 2, Ibrahim Kedir Amdela — CTC-283-26
- 3, Hiba Abdulhamid Mohammed — CTC-2402-26
- 4, Mahlet Tadesse Gebreselasse — CTC-1020-26
- 5, Markon Tamirat Hailu — CTC-7813-26

## 📌 Overview

**HabeshaFreight Mobile** is a cross-platform Flutter application providing role-tailored interfaces for Ethiopian regional road transport logistics. It connects cargo owners (shippers), commercial drivers, transport fleet managers, and corridor operations officers into a single, synchronized digital workflow.

---

## 🎥 Demo Video

[![Watch Project Demo](https://img.shields.io/badge/▶%20Watch%20Demo-Awesome%20Screenshot-0080FF?style=for-the-badge&logo=googlechrome&logoColor=white)](https://www.awesomescreenshot.com/video/57793490?key=44418869b6f6497f05378f28b54dbb83)

> 📺 **Watch the full project walkthrough demo:**  
> 🔗 [https://www.awesomescreenshot.com/video/57793490?key=44418869b6f6497f05378f28b54dbb83](https://www.awesomescreenshot.com/video/57793490?key=44418869b6f6497f05378f28b54dbb83)

---

## 🚀 Key Modules & Capabilities

- 🔐 **Authentication & Onboarding:** Phone/Email OTP authentication, role-based session restore (`AuthGate`), and persistent secure tokens.
- 📦 **Shipper Workspace:** Publish cargo requests, review driver bids, manage active shipments, track escrow balances, and rate carriers.
- 🚛 **Driver Workspace:** Browse available freight along key corridors, submit bids, receive direct cargo offers, and perform OTP pickup/delivery handovers.
- 🏢 **Fleet Command Hub:** Real-time rig telemetry, driver rosters, dispatch matrices, fuel/toll tracking, maintenance orders, and batch escrow settlements.
- 🛂 **Corridor & Border Operations:** Border pass verification, cold-chain temperature telemetry, weighbridge compliance, and customs clearance hubs.

---

## 🛠 Tech Stack

- **Framework:** Flutter 3.x (Dart 3.x)
- **State Management:** Provider
- **Networking:** HTTP REST client with configurable API base URLs
- **Persistence:** SharedPreferences (JWT session & user metadata)
- **Typography & Styling:** Google Fonts (`Plus Jakarta Sans`), Dark Nocturne Corridor Design System

---

## 📂 Architecture & Directory Layout

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/          # API base endpoints & configuration
│   │   ├── routing/         # Application routes & navigation
│   │   ├── services/        # Service clients (Auth, Driver, Shipper, Escrow, Bids)
│   │   └── theme/           # Design system tokens, colors & typography
│   ├── data/
│   │   └── models/          # Data transfer models (Loads, Shipments, Bids, Fleet)
│   ├── presentation/
│   │   └── screens/         # Role-specific UI screens (Auth, Driver, Shipper, Fleet, Ops)
│   └── main.dart            # Flutter application entrypoint
├── test/                    # Unit & widget test suites
└── pubspec.yaml             # Dependencies and package configuration
```

---

## 🏁 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22+ recommended)
- Android Studio / Xcode / VS Code with Flutter extension
- Running HabeshaFreight backend instance (`http://localhost:5000` or local network IP)

### 2. Installation & Run
```bash
# Navigate to the mobile directory
cd mobile

# Fetch dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### 3. Running Automated Tests
```bash
# Execute widget and unit tests
flutter test
```
