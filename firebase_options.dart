// Path: lib/firebase_options.dart
//
// MANUAL SETUP — Fill in values from Firebase Console:
// console.firebase.google.com → Your Project → Project Settings → General
// → Scroll to "Your apps" → click your Android app (com.alfrugan.sheiks)
//
// DO NOT commit this file to public repos — it contains your project credentials.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured. Run flutterfire configure to add web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Android ──────────────────────────────────────────────────────────────
  // Get these from: Firebase Console → Project Settings → Your Android app
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_zvkkSpNbgJcgdOFwXXW9RVRBB73vslg',
    appId: '1:553266138089:android:838f73d0748d1b96255978',
    messagingSenderId: '553266138089',
    projectId: 'alfrugan-app',
    storageBucket: 'alfrugan-app.firebasestorage.app',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  // Get these from: Firebase Console → Project Settings → Your iOS app
  // If you haven't added an iOS app yet, duplicate the android values for now
  // and add iOS properly when you need it.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PASTE_YOUR_IOS_API_KEY_HERE',
    appId: 'PASTE_YOUR_IOS_APP_ID_HERE',
    // Format: 1:123456789:ios:abcdef123456
    messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',
    projectId: 'PASTE_YOUR_PROJECT_ID_HERE',
    storageBucket: 'PASTE_YOUR_STORAGE_BUCKET_HERE',
    iosClientId: 'PASTE_YOUR_IOS_CLIENT_ID_HERE',
    // Found: GoogleService-Info.plist → CLIENT_ID
    iosBundleId: 'com.alfrugan.sheiks',
    // Must match your iOS bundle identifier exactly
  );
}
