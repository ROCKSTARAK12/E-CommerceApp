// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB_pRvszc6upUe4axu1e0Wyt1ZQet4nXUI',
    appId: '1:631930255233:web:your-web-app-id',
    messagingSenderId: '631930255233',
    projectId: 'e-commerce-app-8c85a',
    authDomain: 'e-commerce-app-8c85a.firebaseapp.com',
    storageBucket: 'e-commerce-app-8c85a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_pRvszc6upUe4axu1e0Wyt1ZQet4nXUI',
    appId: '1:631930255233:android:0aae07fb7ec16680df1a80',
    messagingSenderId: '631930255233',
    projectId: 'e-commerce-app-8c85a',
    storageBucket: 'e-commerce-app-8c85a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_pRvszc6upUe4axu1e0Wyt1ZQet4nXUI',
    appId: '1:631930255233:ios:your-ios-app-id',
    messagingSenderId: '631930255233',
    projectId: 'e-commerce-app-8c85a',
    storageBucket: 'e-commerce-app-8c85a.firebasestorage.app',
    iosBundleId: 'com.example.eCommerceApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_pRvszc6upUe4axu1e0Wyt1ZQet4nXUI',
    appId: '1:631930255233:ios:your-macos-app-id',
    messagingSenderId: '631930255233',
    projectId: 'e-commerce-app-8c85a',
    storageBucket: 'e-commerce-app-8c85a.firebasestorage.app',
    iosBundleId: 'com.example.eCommerceApp',
  );
}
