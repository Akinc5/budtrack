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
    apiKey: 'AIzaSyCE2oEgveTiVEaq2qqwtatK0n3GURd2Pv8',
    appId: '1:1042667665262:web:8f9a8c981530d8c6a5337f',
    messagingSenderId: '1042667665262',
    projectId: 'budget-3bdf3',
    authDomain: 'budget-3bdf3.firebaseapp.com',
    storageBucket: 'budget-3bdf3.firebasestorage.app',
    measurementId: 'G-5FYM5K8E0T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAi9MOufRh1QLbz2KErLMttzhxBvqTbSQw',
    appId: '1:1042667665262:android:46401547ff28357ca5337f',
    messagingSenderId: '1042667665262',
    projectId: 'budget-3bdf3',
    storageBucket: 'budget-3bdf3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1mTbz7WNM1n68GRGyd-oACxePvld5eKY',
    appId: '1:1042667665262:ios:d3623dd4d23dd890a5337f',
    messagingSenderId: '1042667665262',
    projectId: 'budget-3bdf3',
    storageBucket: 'budget-3bdf3.firebasestorage.app',
    iosBundleId: 'com.example.chatbud',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1mTbz7WNM1n68GRGyd-oACxePvld5eKY',
    appId: '1:1042667665262:ios:d3623dd4d23dd890a5337f',
    messagingSenderId: '1042667665262',
    projectId: 'budget-3bdf3',
    storageBucket: 'budget-3bdf3.firebasestorage.app',
    iosBundleId: 'com.example.chatbud',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCE2oEgveTiVEaq2qqwtatK0n3GURd2Pv8',
    appId: '1:1042667665262:web:3dc72d8cd304f33ba5337f',
    messagingSenderId: '1042667665262',
    projectId: 'budget-3bdf3',
    authDomain: 'budget-3bdf3.firebaseapp.com',
    storageBucket: 'budget-3bdf3.firebasestorage.app',
    measurementId: 'G-9GR6RMBHMP',
  );
}
