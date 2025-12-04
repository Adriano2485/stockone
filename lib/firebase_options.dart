// ignore_for_file: constant_identifier_names

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
      default:
        throw UnsupportedError(
          'This platform is not supported yet.',
        );
    }
  }

  // CONFIGURAÇÃO PARA WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDOqVO7y3UBNASxgPvNnf2i31Ai6WAlK1k",
    authDomain: "stockone-1c804.firebaseapp.com",
    projectId: "stockone-1c804",
    storageBucket: "stockone-1c804.firebasestorage.app",
    messagingSenderId: "567717670633",
    appId: "1:567717670633:web:9953d6c9cc838046f24a78",
    measurementId: "G-WRWM1CJ2QJ",
  );

  // CONFIGURAÇÃO SIMPLES PARA ANDROID
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDOqVO7y3UBNASxgPvNnf2i31Ai6WAlK1k",
    projectId: "stockone-1c804",
    storageBucket: "stockone-1c804.firebasestorage.app",
    messagingSenderId: "567717670633",
    appId: "1:567717670633:web:9953d6c9cc838046f24a78",
  );

  // CONFIGURAÇÃO SIMPLES PARA iOS (não usada no FlutLab)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDOqVO7y3UBNASxgPvNnf2i31Ai6WAlK1k",
    projectId: "stockone-1c804",
    storageBucket: "stockone-1c804.firebasestorage.app",
    messagingSenderId: "567717670633",
    appId: "1:567717670633:web:9953d6c9cc838046f24a78",
    iosClientId: "",
    iosBundleId: "",
  );
}
