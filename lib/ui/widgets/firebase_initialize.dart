import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:prime_web/utils/constants.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessageLocal(NotificationResponse message) async {
  await Firebase.initializeApp();
}

class FirebaseInitialize {
  final _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;
  Future<void> initFirebaseState(BuildContext context) async {
    channel = const AndroidNotificationChannel(
      androidPackageName,
      appName,
      description: appName,
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher_squircle');
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestBadgePermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
      notificationCategories: [],
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // TODO(J): is it incomplete: onSelectNotification
    Future<void> onSelectNotification(String? payload) async {}

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            onSelectNotification(notificationResponse.payload);

          case NotificationResponseType.selectedNotificationAction:
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundMessageLocal,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    Future<void> generateSimpleNotification(String title, String msg) async {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: notificationIcon,
      );

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: const DarwinNotificationDetails(),
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        msg,
        platformChannelSpecifics,
      );
    }

    Future<String> _downloadAndSaveFile(String url, String fileName) async {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final response = await http.get(Uri.parse(url));
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    }

    Future<void> generateImageNotification(
      String title,
      String msg,
      String image,
    ) async {
      final largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
      final bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
      final bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
        summaryText: msg,
        htmlFormatSummaryText: true,
      );
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: notificationIcon,
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        styleInformation: bigPictureStyleInformation,
      );

      final platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        msg,
        platformChannelSpecifics,
      );
    }

    await _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {}
    });

    await _firebaseMessaging.getToken().then((value) {
      log('token==$value');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('${message.toMap()}');

      final notification = message.notification!;
      final title = notification.title ?? '';
      final body = notification.body ?? '';
      var image = '';

      image = defaultTargetPlatform == TargetPlatform.android
          ? notification.android!.imageUrl ?? ''
          : notification.apple!.imageUrl ?? '';

      if (image != '') {
        generateImageNotification(title, body, image);
      } else {
        generateSimpleNotification(title, body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final notification = message.notification!;
      final body = notification.body ?? '';
    });
  }
}
