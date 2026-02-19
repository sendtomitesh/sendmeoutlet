import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:sendme_outlet/flutter_project_imports.dart';

late FlutterLocalNotificationsPlugin _localNotifications;

/// Request notification permission (required on Android 13+). Call early in app flow.
Future<void> requestNotificationPermissionIfNeeded() async {
  if (!Platform.isAndroid) return;
  final status = await Permission.notification.status;
  if (status.isGranted) return;
  if (status.isPermanentlyDenied) return;
  await Permission.notification.request();
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (!Platform.isAndroid) return;
  // System auto-shows when FCM has notification block (uses SendMe_1 channel) - skip to avoid duplicate.
  if (message.notification != null) return;

  final data = message.data;
  final title = message.notification?.title ??
      data['title'] ??
      data['Title'] ??
      'New Order';
  final body = message.notification?.body ??
      data['body'] ??
      data['message'] ??
      data['Message'] ??
      'You have a new order';

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  const channel = AndroidNotificationChannel(
    'SendMe_1',
    'Partner_Notification',
    description: 'Partner Notification Channel',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('outlet_notify'),
    audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
    enableVibration: true,
  );
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'SendMe_1',
      'Partner_Notification',
      channelDescription: 'Partner Notification Channel',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('outlet_notify'),
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'outlet_notify.caf',
    ),
  );
  await plugin.show(
    message.hashCode % 0x7FFFFFFF,
    title,
    body,
    details,
  );
}

Future<void> initializeNotificationService() async {
  await Firebase.initializeApp();

  _localNotifications = FlutterLocalNotificationsPlugin();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  await _localNotifications.initialize(
    const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    ),
  );

  if (Platform.isAndroid) {
    await _createAndroidNotificationChannel();
  }

  final messaging = FirebaseMessaging.instance;

  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  messaging.getToken().then((token) {
    if (token != null) {
      _updateToken(token);
    }
  }).catchError((e) {
    logPrint('FCM getToken error: $e');
  });

  messaging.onTokenRefresh.listen((token) {
    _updateToken(token);
  });

  FirebaseMessaging.onMessage.listen(_onMessage);

  FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleNotificationData(initialMessage.data);
  }
}

Future<void> _createAndroidNotificationChannel() async {
  const channel = AndroidNotificationChannel(
    'SendMe_1',
    'Partner_Notification',
    description: 'Partner Notification Channel',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('outlet_notify'),
    audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
    enableVibration: true,
  );

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void _onMessage(RemoteMessage message) {
  logPrint('FCM onMessage: ${message.data}');

  final data = message.data;
  var title = message.notification?.title ?? data['title'] ?? data['Title'] ?? 'New Order';
  var body = message.notification?.body ?? data['body'] ?? data['message'] ?? data['Message'] ?? 'You have a new order';

  _showOutletNotification(0, title, body);

  if (data['notificationTo'] != null &&
      int.tryParse(data['notificationTo'].toString()) == GlobalConstants.Outlet) {
    GlobalConstants.streamController.add('outletNotify');
  }
  GlobalConstants.streamController.add('notification');
}

void _onMessageOpenedApp(RemoteMessage message) {
  _handleNotificationData(message.data);
}

void _handleNotificationData(Map<String, dynamic> data) {
  if (data['notificationTo'] != null &&
      int.tryParse(data['notificationTo'].toString()) == GlobalConstants.Outlet) {
    GlobalConstants.streamController.add('outletNotify');
  }
}

Future<void> _showOutletNotification(
  int id,
  String title,
  String body,
) async {
  const androidDetails = AndroidNotificationDetails(
    'SendMe_1',
    'Partner_Notification',
    channelDescription: 'Partner Notification Channel',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('outlet_notify'),
    audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
    enableVibration: true,
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'outlet_notify.caf',
  );

  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _localNotifications.show(id, title, body, details);
}

Future<void> _updateToken(String token) async {
  if (token == GlobalConstants.FIREBASE_TOKEN) return;
  if (!await GlobalConstants.checkInternetConnection()) return;

  final userData = await PreferencesHelper.readStringPref(
    PreferencesHelper.prefUserData,
  );

  if (userData == null || userData.isEmpty) return;

  try {
    final jsonData = json.decode(userData);
    final userJson = jsonData['Data'] as Map<String, dynamic>;
    final userId = userJson['userId'] ?? userJson['UserId'];

    final url =
        '${ApiPath.updateUserToken}token=$token'
        '&userType=${GlobalConstants.Outlet}'
        '&deviceType=${GlobalConstants.Device_Type}'
        '&version=${GlobalConstants.App_Version}'
        '&userId=$userId'
        '&deviceId=${GlobalConstants.Device_Id}'
        '&packageName=${ThemeUI.appPackageName}';

    final response = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 15),
        );
    logPrint('UpdateToken response: ${response.statusCode} body: ${response.body}');
  } catch (e) {
    logPrint('UpdateToken error: $e');
  }

  GlobalConstants.FIREBASE_TOKEN = token;
}

/// Call after login to ensure FCM token is sent to backend.
Future<void> refreshFcmTokenAfterLogin() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await _updateToken(token);
  }
}
