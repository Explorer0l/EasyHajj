import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Placeholder Firebase configuration to keep the project compiling.
///
/// Replace these values by running:
/// `dart pub global activate flutterfire_cli`
/// `flutterfire configure`
///
/// The generated file can safely overwrite this one.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_ANDROID_MSG_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_MSG_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    iosBundleId: 'com.easyhajj.app',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'windows-key',
    appId: 'windows-app',
    messagingSenderId: 'windows-sender',
    projectId: 'YOUR_PROJECT_ID',
  );

  static const FirebaseOptions linux = windows;
}

