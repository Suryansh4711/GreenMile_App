# GreenMile - Eco-Friendly Travel Tracker

GreenMile is a Flutter application that helps users track their eco-friendly travel choices and monitor their environmental impact.

## Features

- 🗺️ **Real-time Trip Tracking**
  - GPS tracking with route visualization
  - Distance calculation
  - Step counter with sensor integration
  - Multiple transport modes support

- 🌱 **Environmental Impact**
  - CO2 emissions tracking
  - Environmental savings calculator
  - Daily, weekly, and monthly statistics

- 📊 **Trip Statistics**
  - Detailed trip history
  - Distance covered
  - Calories burned
  - Average speed

- 🔐 **User Features**
  - Profile management
  - Trip history
  - Local data storage
  - Dark/Light theme support

## Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK (^3.0.0)
- Android Studio / VS Code
- Google Maps API Key

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/greenmile.git
    ```

2. Install dependencies:
    ```bash
    flutter pub get
    ```

3. Add your Google Maps API key in:
    - `android/app/src/main/AndroidManifest.xml`
    - `ios/Runner/AppDelegate.swift`

4. Run the app:
    ```bash
    flutter run
    ```

## Dependencies

- google_maps_flutter: ^2.5.0
- geolocator: ^10.1.0
- sensors_plus: ^3.1.0
- shared_preferences: ^2.2.2
- provider: ^6.0.5
- fl_chart: ^0.66.0

## Architecture

The app follows a clean architecture pattern with:
- Services for business logic
- Models for data structure
- Providers for state management
- Pages for UI components

## Project Structure

```
lib/
├── main.dart                # App entry point
├── models/                  # Data models
│   ├── trip_details.dart   # Trip model
│   └── emission_result.dart # Emissions calculations
│
├── pages/                   # UI screens
│   ├── home_page.dart      # Main dashboard
│   ├── add_trip_page.dart  # Add new trip
│   ├── my_trips_page.dart  # Trip history
│   ├── track_page.dart     # Real-time tracking
│   ├── profile_page.dart   # User profile
│   └── settings_page.dart  # App settings
│
├── services/               # Business logic
│   ├── auth_service.dart  # Authentication
│   ├── data_service.dart  # Data management
│   ├── location_service.dart # Location tracking
│   └── steps_service.dart   # Step counting
│
└── widgets/               # Reusable components
    ├── stat_card.dart    # Statistics display
    └── trip_card.dart    # Trip list item

assets/                   # Static resources
├── images/              # App images
└── icons/               # App icons

test/                    # Unit and widget tests
└── widget_test.dart     # UI component tests
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
