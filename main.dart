import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'config/dependency_injection.dart';
import 'core/utils/notification_helper.dart';
import 'services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Unique ID for our periodic reschedule alarm
const int _rescheduleAlarmId = 888;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 2. Local notifications
  await NotificationHelper.initialize();

  // 3. CRITICAL: check exact-alarm + battery permissions first
  final bool canSchedule = await NotificationHelper.ensureCriticalPermissions();

  // 4. Only schedule when we have exact-alarm permission
  if (canSchedule) {
    await NotificationHelper.scheduleAdhkarReminders();
  } else {
    // You can show a dialog here telling the user to enable
    // "Alarms & reminders" in system settings for the app.
    debugPrint('App opened without exact-alarm permission – skipping schedule');
  }

  // 5. DI, orientation, etc.
  await DependencyInjection.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final container = ProviderContainer();
  FcmService.instance.setContainer(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const QuranSheikhApp(),
    ),
  );
}
