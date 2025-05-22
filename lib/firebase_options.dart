import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDrkrgq0aH1a_huwSQiDH1ogfShrFZGxog',  // Get from google-services.json
          appId: '1:795080023256:android:a711d663c499e2c2500bad',    // Get from google-services.json
          messagingSenderId: 'YOUR-ACTUAL-SENDER-ID',
          projectId: 'greenmile-app',
          storageBucket: 'greenmile-app.firebasestorage.app',
        );
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
