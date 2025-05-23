# GreenMile - Eco-friendly Transportation Tracker

GreenMile is a Flutter application that helps users track their transportation choices and their environmental impact, encouraging eco-friendly travel options.

## Features

- **Trip Logging & Analysis**
  - Manual trip entry with transportation mode
  - Support for electric and conventional vehicles
  - Real-time emissions calculations
  - Automatic trip detection and tracking

- **Environmental Impact Tracking**
  - CO₂ emissions saved
  - NOx and SO₂ tracking
  - Real-time environmental impact calculations
  - Daily and monthly statistics

- **Activity Monitoring**
  - Step counting
  - Distance tracking
  - Calorie burn calculations
  - Active time monitoring

- **Dashboard & Visualization**
  - Real-time statistics
  - Interactive charts
  - Progress tracking
  - Achievement badges

## Project Structure

```
lib/
├── main.dart              # App entry point and theme configuration
├── models/
│   ├── emission_result.dart    # Emission calculation model
│   └── trip_details.dart       # Trip data structure
├── pages/
│   ├── add_trip_page.dart      # New trip logging interface
│   ├── challenges_page.dart    # Environmental challenges
│   ├── home_page.dart         # Main dashboard
│   ├── login_page.dart        # Authentication
│   ├── my_trips_page.dart     # Trip history
│   ├── ocr_page.dart          # Document scanning
│   ├── profile_page.dart      # User profile
│   ├── rewards_page.dart      # Achievement rewards
│   ├── settings_page.dart     # App configuration
│   └── track_page.dart        # Real-time tracking
├── services/
│   ├── auth_service.dart      # Authentication handling
│   ├── data_service.dart      # Data management
│   ├── location_service.dart  # Location tracking
│   ├── ocr_service.dart       # Document processing
│   └── steps_service.dart     # Step counting
└── widgets/
    └── animated_stat_card.dart # Reusable UI components
```

## Setup & Installation

1. Clone the repository
    ```bash
    git clone https://github.com/yourusername/greenmile_fixed.git
    ```

2. Install dependencies
    ```bash
    flutter pub get
    ```

3. Configure Firebase
    - Add your `google-services.json` to `android/app/`
    - Add your `GoogleService-Info.plist` to `ios/Runner/`

4. Run the app
    ```bash
    flutter run
    ```

## Environment Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Android SDK: 21 or newer
- iOS: 11.0 or newer

## Dependencies

Main packages used:
- firebase_core
- firebase_auth
- provider
- google_maps_flutter
- sensors_plus
- fl_chart
- shared_preferences

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
