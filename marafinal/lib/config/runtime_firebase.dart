import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

FirebaseOptions firebaseFromEnv() {
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.android) {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
    );
  } else if (platform == TargetPlatform.iOS) {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
      iosClientId: dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '',
      iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'],
    );
  }
  throw UnsupportedError('Unsupported platform for Firebase configuration');
}

List<String> missingFirebaseKeys() {
  final platform = defaultTargetPlatform;
  final requiredBase = [
    'FIREBASE_PROJECT_ID',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_STORAGE_BUCKET',
  ];
  final requiredAndroid = [
    'FIREBASE_ANDROID_API_KEY',
    'FIREBASE_ANDROID_APP_ID',
  ];
  final requiredIOS = [
    'FIREBASE_IOS_API_KEY',
    'FIREBASE_IOS_APP_ID',
    'FIREBASE_IOS_CLIENT_ID',
    'FIREBASE_IOS_BUNDLE_ID',
  ];

  final all = <String>[]..addAll(requiredBase);
  if (platform == TargetPlatform.android) all.addAll(requiredAndroid);
  if (platform == TargetPlatform.iOS) all.addAll(requiredIOS);

  return all.where((k) => (dotenv.env[k] ?? '').trim().isEmpty).toList();
}
