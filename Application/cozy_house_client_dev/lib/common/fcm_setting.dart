import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print('Handling a background message: ${message.messageId}');
}

Future<String?> fcmSetting() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Cozy House Notification',
    'Cozy House Notification',
    description: '포근한 집 알림입니다.',
    importance: Importance.max
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print(notification);
    print(android);

    print('Got a message whilst in the foreground!');
    print('Message data!: ${message.data}');


    if (message.notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          )
        )
      );

      print('Message also contained a notification: ${message.notification}');
    }
  });


  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
  //   if (message != null) {
  //     print('Got a message whilst in the background!');
  //     print('Message data!: ${message.data}');
  //
  //     if (message.notification != null) {
  //       print(message.notification!.title);
  //       print(message.notification!.body);
  //       print(message.data["click_action"]);
  //     }
  //   }
  // });
  //
  // FirebaseMessaging.instance
  //     .getInitialMessage()
  //     .then((RemoteMessage? message) {
  //   if (message != null) {
  //     print('Got a message whilst in the terminated!');
  //     print('Message data!: ${message.data}');
  //     if (message.notification != null) {
  //       print(message.notification!.title);
  //       print(message.notification!.body);
  //       print(message.data["click_action"]);
  //     }
  //   }
  // });

  String? firebaseToken = await messaging.getToken();

  print('firebaseToken : ${firebaseToken}');

  return firebaseToken;
}