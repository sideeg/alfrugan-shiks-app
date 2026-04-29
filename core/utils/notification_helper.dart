// Path: lib/core/utils/notification_helper.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:quran_sheikh_app/core/constants/route_constants.dart';
import 'package:quran_sheikh_app/presentation/navigation/app_router.dart';
import 'package:permission_handler/permission_handler.dart';
// تم الاستغناء عن استدعاء adhkar_data.dart لأننا وضعنا القوائم هنا لتكون مستقلة وعشوائية.

class NotificationHelper {
  NotificationHelper._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'sheikh_alerts';
  static const _channelName = 'تنبيهات الشيخ';
  static const _channelDescription = 'إشعارات الطلاب والدورات والمجموعات';

  static const _adhkarChannelId = 'adhkar_reminders';
  static const _adhkarChannelName = 'تنبيهات الأذكار';
  static const _adhkarChannelDesc = 'تذكير بأذكار الصباح والمساء';

  // ── Scheduling constants ─────────────────────────────────────────────────
  static const int _morningHour = 6; // 06:00 AM
  static const int _morningMinute = 0;
  static const int _eveningHour = 17; // 17:00 (05:00 PM)
  static const int _eveningMinute = 30;
  static const int _daysAhead = 30; // how many days to pre-schedule

  // =========================================================================
  // ── قوائم الأذكار المخصصة ───────────────────────────────────────────────
  // =========================================================================
  static const List<Map<String, String>> _morning = [
    {
      'title': 'إشراقة جديدة ☀️',
      'body':
          'ابدأ يومك بذكر الله لتنال البركة والتوفيق في كل خطوة. أذكار الصباح بانتظارك.'
    },
    {
      'title': 'حصن يومك 🛡️',
      'body':
          'أذكار الصباح هي حصنك الحصين من كل شر ومكروه. لا تخرج من بيتك قبل أن تتحصن.'
    },
    {
      'title': 'صلاة وتسبيح 🌅',
      'body':
          '"فاصبر وسبح بحمد ربك قبل طلوع الشمس".. ابدأ رحلة يومك بتسبيحة تزيح عنك الهم وتفتح لك الأبواب.'
    },
    {
      'title': 'حين تقوم.. 🛡️',
      'body':
          '"واذكر ربك حين تقوم".. أولى لحظات يومك هي الأهم، فلا تنسَ عهدك مع الله في أذكار الصباح.'
    },
    {
      'title': 'عهد جديد مع الله 🤲',
      'body':
          '"اللهم بك أصبحنا".. رددها بيقين ليبارك الله لك في وقتك وعملك اليوم.'
    },
    {
      'title': 'لسانٌ رطب 💧',
      'body':
          'أوصى النبي ﷺ رجلاً بشيء يتشبث به فقال: "لا يزال لسانك رطباً بذكر الله". عطّر فمك واكسب أجرك الآن.'
    },
    {
      'title': 'صباح الذاكرين 🕊️',
      'body':
          'أنر صباحك بكلمات تقربك من خالقك، واطرد همومك. هل قرأت أذكارك اليوم؟'
    },
    {
      'title': 'كن من السبّاقين 🏃‍♂️',
      'body':
          'قال ﷺ: "سبق المُفَرِّدون"، قالوا: وما المفردون؟ قال: "الذاكرون الله كثيراً والذاكرات". لا تتخلف عن الركب!'
    },
    {
      'title': 'سيد الاستغفار 👑',
      'body':
          'من قاله موقناً به ومات من يومه دخل الجنة. هل طرقت باب المغفرة اليوم؟ اقرأ سيد الاستغفار في أذكارك.'
    },
    {
      'title': 'ألا بذكر الله تطمئن القلوب ❤️',
      'body':
          'دقائق قليلة تقضيها في ذكر الله قادرة على إزاحة جبال من الهموم عن صدرك.'
    },
    {
      'title': 'أنيسك في الطريق 🛣️',
      'body':
          '"قياماً وقعوداً".. اجعل لسانك رطباً بذكر الله وأنت في طريقك، فالله معك أينما كنت.'
    },
    {
      'title': 'هل نسيت شيئاً مهماً؟ 💡',
      'body':
          'زحام الحياة قد ينسينا أعظم زاد. توقف لحظة، وخذ نفساً، واذكر الله.'
    },
    {
      'title': 'رضى الرحمن 🤲',
      'body':
          '"من قال: رضيت بالله رباً، وبالإسلام ديناً، وبمحمد نبياً، وجبَتْ له الجنة". قلها بيقين في صباحك.'
    },
    {
      'title': 'مفتاح الرزق 🔑',
      'body':
          'من بدأ يومه بذكر الله، تكفل الله به وأرضاه. دقائق قليلة تفتح لك أبواب الخير.'
    },
    {
      'title': 'أحب الكلام إلى الله ❤️',
      'body':
          '"أحب الكلام إلى الله أربع: سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر". لا تبخل على نفسك بهذا الأجر.'
    },
    {
      'title': 'مطلع النور ✨',
      'body':
          'طهر أنفاسك بذكر الله قبل أن تشرق الشمس، لتشرق الطمأنينة في قلبك طوال اليوم.'
    },
    {
      'title': 'كفاية للهموم ☁️',
      'body':
          'حين تكثر الصلاة على النبي ﷺ "يُكفى همك، ويُغفر ذنبك". اجعل له نصيباً من ذكرك اليوم.'
    },
  ];

  static const List<Map<String, String>> _evening = [
    {
      'title': 'سكنٌ وراحة 🌙',
      'body':
          'بعد عناء النهار، اختم يومك بذكر الله لتطمئن روحك ويهدأ قلبك. حان وقت أذكار المساء.'
    },
    {
      'title': 'قبل الغروب 🌆',
      'body':
          '"وسبح بحمد ربك قبل طلوع الشمس وقبل الغروب".. اختم يومك بكلمات يحبها الرحمن، اقرأ أذكارك الآن.'
    },
    {
      'title': 'أمانٌ في ليلتك 🌌',
      'body':
          'أذكار المساء أمان وحفظ لك حتى تصبح. لا تحرم نفسك هذا الفضل العظيم، اقرأها الآن.'
    },
    {
      'title': 'نبض الحياة 💓',
      'body':
          'قال ﷺ: "مثل الذي يذكر ربه والذي لا يذكر ربه مَثَلُ الحي والميت". أحيِ قلبك الآن بذكر الله.'
    },
    {
      'title': 'ختام مسك ✨',
      'body':
          'طيِّب صحيفتك في نهاية هذا اليوم بذكر الله. دقائق من وقتك تجلب لك طمأنينة الليل.'
    },
    {
      'title': 'نداء السكينة 🌌',
      'body':
          '"ومن آناء الليل فسبح".. اجعل لنفسك نصيباً من ذكر الله قبل المبيت لتنام في حفظ الله ورعايته.'
    },
    {
      'title': 'غراس الجنة 🌴',
      'body':
          'لقِيَ النبي ﷺ إبراهيم الخليل فأوصاه لأمته: "أخبرهم أن الجنة طيعة التربة.. وأن غراسها: سبحان الله والحمد لله". ازرع غراسك.'
    },
    {
      'title': 'في كل أحوالك 🚶‍♂️',
      'body':
          '"الذين يذكرون الله قياماً وقعوداً وعلى جنوبهم".. كن مع الله في كل حركة وسكون، اذكر الله الآن.'
    },
    {
      'title': 'كنز في ميزانك ⚖️',
      'body':
          '"كلمتان خفيفتان على اللسان، ثقيلتان في الميزان: سبحان الله وبحمده، سبحان الله العظيم". رددها الآن.'
    },
    {
      'title': 'زاد الروح 🕯️',
      'body':
          'كما أطعمت جسدك اليوم، لا تنسَ غذاء روحك. أذكار المساء حصن وسكينة.'
    },
    {
      'title': 'كفاية من كل شيء 🛡️',
      'body':
          'قال ﷺ عن المعوذات وقل هو الله أحد: "تكفيك من كل شيء" إذا قلتها حين تمسي وحين تصبح. حصّن نفسك الآن.'
    },
    {
      'title': 'تجارة لن تبور 📈',
      'body':
          '"واذكر ربك إذا نسيت".. إن غفلت في زحام العمل، فعد الآن إلى واحة الذكر، فهو الربح الحقيقي.'
    },
    {
      'title': 'شكر النعم 🤲',
      'body':
          'مضى النهار بحلوه ومره، فاشكر الله على نعمه التي لا تعد ولا تحصى. أذكار المساء تنتظرك.'
    },
    {
      'title': 'صلاةٌ وسلام 🕊️',
      'body':
          'قال ﷺ: "من صلّى عليّ صلاة واحدة، صلّى الله عليه عشر صلوات". عطّر وقتك بالصلاة على الحبيب.'
    },
    {
      'title': 'وصية غالية 💎',
      'body':
          '"واصبر نفسك مع الذين يدعون ربهم".. رفقاء الذكر هم السند، والتطبيق يذكرك لتبقى في ركب الذاكرين.'
    },
    {
      'title': 'كن من الذاكرين 👑',
      'body':
          '(والذاكرين الله كثيراً والذاكرات).. اجعل لنفسك نصيباً من هذه الآية العظيمة في هذا المساء.'
    },
    {
      'title': 'زاد المساء 🕯️',
      'body':
          'كما تغرب الشمس، تذهب الهموم بالاستغفار والذكر. حصن نفسك وأهلك بأذكار المساء.'
    },
  ];

  /// Call this from main() BEFORE scheduleAdhkarReminders()
  static Future<bool> ensureCriticalPermissions() async {
    if (!Platform.isAndroid) return true;

    // 1. Notification permission (Android 13+)
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    // 2. Exact alarm permission (Android 12+) – MUST be granted or
    //    exactAllowWhileIdle falls back to inexact and gets batched by Doze.
    final exactAlarm = await Permission.scheduleExactAlarm.status;
    if (!exactAlarm.isGranted) {
      final req = await Permission.scheduleExactAlarm.request();
      if (!req.isGranted) {
        debugPrint(
            '❌ Exact alarm permission denied – notifications will be delayed by Doze');
        return false;
      }
    }

    // 3. Battery optimization – so alarms survive when the app is swiped away
    final battery = await Permission.ignoreBatteryOptimizations.status;
    if (!battery.isGranted) {
      final req = await Permission.ignoreBatteryOptimizations.request();
      if (!req.isGranted) {
        debugPrint(
            '⚠️ Battery optimization active – some OEMs may kill alarms');
      }
    }

    return true;
  }

  // ── Initialize ──────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    // 1. إعداد التوقيت المحلي لتجنب مشاكل المناطق الزمنية
    tz.initializeTimeZones();
    final dynamic tzData = await FlutterTimezone.getLocalTimezone();
    String localName;

    if (tzData is String) {
      localName = tzData;
    } else {
      localName = tzData.identifier;
    }
    tz.setLocalLocation(tz.getLocation(localName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // تم تفعيل الصلاحيات لتعمل الجدولة في iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createAndroidChannels();
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
    );

    const adhkarChannel = AndroidNotificationChannel(
      _adhkarChannelId,
      _adhkarChannelName,
      description: _adhkarChannelDesc,
      importance: Importance.high,
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(adhkarChannel);
  }

  // ── Show foreground notification (للفايربيس) ──────────────────────────────

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFD4A843),
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  static String buildPayload(Map<String, dynamic> data) {
    final type = data['type']?.toString() ?? '';
    final groupId = data['group_id']?.toString() ?? '';
    final courseId = data['course_id']?.toString() ?? '';
    return '$type|$groupId|$courseId';
  }

  static Future<void> cancelAll() async => _plugin.cancelAll();

  // ── جدولة الأذكار للأيام القادمة (النسخة الجديدة 30 يوم) ─────────────────

  static Future<void> scheduleAdhkarReminders() async {
    final List<PendingNotificationRequest> pending =
        await _plugin.pendingNotificationRequests();

    // نقوم بفلترة الإشعارات المحلية الخاصة بالأذكار (التي برمجناها لتبدأ الآي دي الخاص بها من 1000)
    final adhkarPending = pending.where((p) => p.id >= 1000).toList();

    // الحماية: إذا كان لدينا على الأقل 10 أيام (20 إشعار) متبقية، فلا نرهق النظام بإعادة الجدولة
    if (adhkarPending.length > 20) {
      debugPrint(
          "🔔 Queue is healthy (${adhkarPending.length} pending). Skipping reschedule.");
      return;
    }

    debugPrint("🔄 Rebuilding 30-day notification queue...");

    // إلغاء إشعارات الأذكار القديمة فقط (حتى لا نمسح إشعارات التطبيق الأخرى لو وجدت)
    for (var p in adhkarPending) {
      await _plugin.cancel(p.id);
    }

    final now = tz.TZDateTime.now(tz.local);
    final random = Random();

    for (int day = 0; day < _daysAhead; day++) {
      final morningEntry = _morning[random.nextInt(_morning.length)];
      final eveningEntry = _evening[random.nextInt(_evening.length)];

      // أرقام معرّفة (IDs) تبدأ من 1000 لتجنب التداخل مع إشعارات FCM
      final morningId = 1000 + (day * 2);
      final eveningId = 1000 + (day * 2) + 1;

      final morningTime = _dayAt(now, day, _morningHour, _morningMinute);
      final eveningTime = _dayAt(now, day, _eveningHour, _eveningMinute);

      if (morningTime.isAfter(now)) {
        await _scheduleLocal(
          id: morningId,
          title: morningEntry['title']!,
          body: morningEntry['body']!,
          scheduledDate: morningTime,
        );
      }

      if (eveningTime.isAfter(now)) {
        await _scheduleLocal(
          id: eveningId,
          title: eveningEntry['title']!,
          body: eveningEntry['body']!,
          scheduledDate: eveningTime,
        );
      }
    }
    debugPrint("✅ Successfully scheduled 30 days of Adhkar.");
  }

  static tz.TZDateTime _dayAt(
      tz.TZDateTime base, int daysOffset, int hour, int minute) {
    return tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      base.day + daysOffset,
      hour,
      minute,
    );
  }

  static Future<void> _scheduleLocal({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _adhkarChannelId,
      _adhkarChannelName,
      channelDescription: _adhkarChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      color: const Color(0xFFD4A843),
      styleInformation: BigTextStyleInformation(body), // لعرض النص كاملاً
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'local_adhkar',
    );
  }

  // ── Tap handling ────────────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;

    if (payload == 'local_adhkar') {
      _navigateTo(RouteConstants.DASHBOARD);
      return;
    }

    if (payload == null || payload.isEmpty) {
      _navigateTo(RouteConstants.NOTIFICATIONS);
      return;
    }

    final parts = payload.split('|');
    final type = parts.isNotEmpty ? parts[0] : '';
    final groupId =
        parts.length > 1 && parts[1].isNotEmpty ? int.tryParse(parts[1]) : null;
    final courseId =
        parts.length > 2 && parts[2].isNotEmpty ? int.tryParse(parts[2]) : null;
    _routeFromPayload(type: type, groupId: groupId, courseId: courseId);
  }

  static void routeFromNotification({
    required String type,
    int? groupId,
    int? courseId,
  }) {
    _routeFromPayload(type: type, groupId: groupId, courseId: courseId);
  }

  // ── Routing logic ───────────────────────────────────────────────────────────

  static void _routeFromPayload({
    required String type,
    int? groupId,
    int? courseId,
  }) {
    switch (type) {
      case 'new_student':
      case 'enrollment':
        _navigateTo(RouteConstants.STUDENTS);
        break;
      case 'course_start':
      case 'course_end':
        _navigateTo(RouteConstants.COURSES);
        break;
      case 'custom_broadcast':
      default:
        _navigateTo(RouteConstants.NOTIFICATIONS);
        break;
    }
  }

  static void _navigateTo(String path) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      GoRouter.of(context).go(path);
    } else {
      debugPrint('[NotificationHelper] ⚠️ Navigator context null');
    }
  }
}
