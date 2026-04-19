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
    apiKey: 'AIzaSyBorJfzx52JJfs0U0OA_B_xYW4X7HumiEM',
    appId: '1:666046041125:web:2lc674r7jivd8pdriing84c06e8ajdbt',
    messagingSenderId: '666046041125',
    projectId: 'gen-lang-client-0833694138',
    authDomain: 'gen-lang-client-0833694138.firebaseapp.com',
    databaseURL: 'https://gen-lang-client-0833694138.firebaseio.com',
    storageBucket: 'gen-lang-client-0833694138.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBorJfzx52JJfs0U0OA_B_xYW4X7HumiEM',
    appId: '1:666046041125:android:25e27c32549227afacc3cc',
    messagingSenderId: '666046041125',
    projectId: 'gen-lang-client-0833694138',
    databaseURL: 'https://gen-lang-client-0833694138.firebaseio.com',
    storageBucket: 'gen-lang-client-0833694138.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDW9G09sHvRwXwIXIvO_sjw-nZC6I78rzU',
    appId: '1:666046041125:ios:2lc674r7jivd8pdriing84c06e8ajdbt',
    messagingSenderId: '666046041125',
    projectId: 'gen-lang-client-0833694138',
    databaseURL: 'https://gen-lang-client-0833694138.firebaseio.com',
    storageBucket: 'gen-lang-client-0833694138.appspot.com',
    iosBundleId: 'com.quizforge.app',
  );
}
