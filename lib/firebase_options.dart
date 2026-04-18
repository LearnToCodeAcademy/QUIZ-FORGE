import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD1234567890abcdefghijk',
    appId: '1:666046041125:web:abcdef1234567890',
    messagingSenderId: '666046041125',
    projectId: 'quizforge-app',
    authDomain: 'quizforge-app.firebaseapp.com',
    databaseURL: 'https://quizforge-app.firebaseio.com',
    storageBucket: 'quizforge-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1234567890abcdefghijk',
    appId: '1:666046041125:android:abcdef1234567890',
    messagingSenderId: '666046041125',
    projectId: 'quizforge-app',
    databaseURL: 'https://quizforge-app.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1234567890abcdefghijk',
    appId: '1:666046041125:ios:abcdef1234567890',
    messagingSenderId: '666046041125',
    projectId: 'quizforge-app',
    databaseURL: 'https://quizforge-app.firebaseio.com',
    iosBundleId: 'com.quizforge.app',
  );
}
