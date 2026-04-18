import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/dependency_injection.dart';
import 'core/utils/notification_helper.dart';
import 'services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialize Firebase ────────────────────────────────────────────────
  // Must happen before any Firebase plugin usage.
  await Firebase.initializeApp();

  // ── 2. Register background message handler ────────────────────────────────
  // This tells Firebase which top-level function to run when a data message
  // arrives while the app is in the background.
  // Must be called AFTER Firebase.initializeApp().
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ── 3. Initialize local notifications ────────────────────────────────────
  // Sets up the Android channel and the tap callback for foreground pushes.
  await NotificationHelper.initialize();

  // ── 4. Initialize dependency injection ───────────────────────────────────
  await DependencyInjection.init();
  // ── 5. Lock to portrait mode (optional — adjust if landscape is needed) ──
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── 6. Create ProviderContainer and share with FcmService ─────────────────
  // FcmService needs to update Riverpod providers from outside the widget
  // tree (inside FCM callbacks). We give it a reference to the container.
  final container = ProviderContainer();
  FcmService.instance.setContainer(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const QuranSheikhApp(),
    ),
  );
}
