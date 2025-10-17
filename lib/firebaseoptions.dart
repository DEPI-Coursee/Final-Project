import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // PASTE YOUR ANDROID KEYS HERE
        return const FirebaseOptions(
          apiKey: "AIzaSyBVHTZHT2BRCBkRFJlvFB-g1AYuPq_dqYw",
          appId: "1:758189748301:android:1c4739870b65a26b186c04",
          messagingSenderId: "758189748301",
          projectId: "tour-a3380",
          storageBucket: "tour-a3380.appspot.com",
        );
      case TargetPlatform.iOS:
        // You can add your iOS keys here later if you need them
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
