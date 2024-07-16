import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

import 'global_key.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize native android notification
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize native Ios Notifications
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        if (payload.payload != null) {
          Map<String, dynamic> data = jsonDecode(payload.payload!);
          navigatorKey.currentState?.pushNamed(data['routeName'], arguments: data['arguments']);
        }
      },
    );

    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void showNotificationAndroid(String title, String value, String? route) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel_id', 'Channel Name',
        channelDescription: 'Channel Description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');

    int notificationId = 1;
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin
        .show(notificationId, title, value, notificationDetails, payload: route);
  }


  void showNotificationIos(String title, String value, String? route) async {
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
        presentAlert: true,  // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        //presentBadge: true,  // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentSound: false,  // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        //sound: String?,  // Specifics the file path to play (only from iOS 10 onwards)
        //badgeNumber: int?, // The application's icon badge number
        //attachments: List<IOSNotificationAttachment>?, (only from iOS 10 onwards)
        //subtitle: String?, //Secondary description  (only from iOS 10 onwards)
        //threadIdentifier: String? (only from iOS 10 onwards)
    );

    int notificationId = 1;

    const NotificationDetails notificationDetails =
    NotificationDetails(iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(notificationId, title, value, notificationDetails, payload: route);
  }

  void showNotification(String title, String value, String? route) async {
    if (Platform.isAndroid) {
      showNotificationAndroid(title, value, route);
    } else if (Platform.isIOS) {
      showNotificationIos(title, value, route);
    } else {
      print('Unsupported platform');
    }
  }
}
