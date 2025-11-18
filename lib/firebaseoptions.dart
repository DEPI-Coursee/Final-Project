import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyBVHTZHT2BRCBkRFJlvFB-g1AYuPq_dqYw",
        appId: "1:758189748301:web:5568214ba53d8a94186c04",
        messagingSenderId: "758189748301",
        projectId: "tour-a3380",
        storageBucket: "tour-a3380.firebasestorage.app",
        authDomain: "tour-a3380.firebaseapp.com",
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
