// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDzSvCpYK0WfRl64c7hptgihhTQrKVxX4E',
    appId: '1:865984224969:web:492c01d16cb52f9c5f3718',
    messagingSenderId: '865984224969',
    projectId: 'user-profile-app-75f6a',
    authDomain: 'user-profile-app-75f6a.firebaseapp.com',
    storageBucket: 'user-profile-app-75f6a.firebasestorage.app',
    measurementId: 'G-4341VZQDJW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTwNJnk0B5PkPlkwR50LIIWeGg-pvNCns',
    appId: '1:865984224969:android:c2cb4fc0b551f4225f3718',
    messagingSenderId: '865984224969',
    projectId: 'user-profile-app-75f6a',
    storageBucket: 'user-profile-app-75f6a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANRRSli0yphIKc4XundAHOtY3rn6LWa-E',
    appId: '1:865984224969:ios:24059726ad34beae5f3718',
    messagingSenderId: '865984224969',
    projectId: 'user-profile-app-75f6a',
    storageBucket: 'user-profile-app-75f6a.firebasestorage.app',
    iosBundleId: 'com.example.userProfileApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANRRSli0yphIKc4XundAHOtY3rn6LWa-E',
    appId: '1:865984224969:ios:24059726ad34beae5f3718',
    messagingSenderId: '865984224969',
    projectId: 'user-profile-app-75f6a',
    storageBucket: 'user-profile-app-75f6a.firebasestorage.app',
    iosBundleId: 'com.example.userProfileApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDzSvCpYK0WfRl64c7hptgihhTQrKVxX4E',
    appId: '1:865984224969:web:66eadf7a3415e5725f3718',
    messagingSenderId: '865984224969',
    projectId: 'user-profile-app-75f6a',
    authDomain: 'user-profile-app-75f6a.firebaseapp.com',
    storageBucket: 'user-profile-app-75f6a.firebasestorage.app',
    measurementId: 'G-2N9DPCKNQJ',
  );

}