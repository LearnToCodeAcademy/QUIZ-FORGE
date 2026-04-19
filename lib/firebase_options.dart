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
    apiKey: 'AIzaSyCTBlCBXH3uCtmo1K9juaZe1kxvv6avtec',
    appId: '1:666046041125:web:2lc674r7jivd8pdriing84c06e8ajdbt',
    messagingSenderId: '666046041125',
    projectId: 'quiz-forge-666046041125',
    authDomain: 'quiz-forge-666046041125.firebaseapp.com',
    databaseURL: 'https://quiz-forge-666046041125.firebaseio.com',
    storageBucket: 'quiz-forge-666046041125.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTBlCBXH3uCtmo1K9juaZe1kxvv6avtec',
    appId: '1:666046041125:android:2lc674r7jivd8pdriing84c06e8ajdbt',
    messagingSenderId: '666046041125',
    projectId: 'quiz-forge-666046041125',
    databaseURL: 'https://quiz-forge-666046041125.firebaseio.com',
    storageBucket: 'quiz-forge-666046041125.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTBlCBXH3uCtmo1K9juaZe1kxvv6avtec',
    appId: '1:666046041125:ios:2lc674r7jivd8pdriing84c06e8ajdbt',
    messagingSenderId: '666046041125',
    projectId: 'quiz-forge-666046041125',
    databaseURL: 'https://quiz-forge-666046041125.firebaseio.com',
    storageBucket: 'quiz-forge-666046041125.appspot.com',
    iosBundleId: 'com.quizforge.app',
  );
}
