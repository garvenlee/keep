import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

// final PublishSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
//     PublishSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>(onListen: () {
  debugPrint('start to listen..............');
}, onCancel: () {
  debugPrint('on cancel....................');
  // selectNotificationSubject.add('0-0');
});

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

// Future<void> initNotifications(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   var initializationSettingsAndroid = AndroidInitializationSettings('login_logo');
//   var initializationSettingsIOS = IOSInitializationSettings(
//       requestAlertPermission: false,
//       requestBadgePermission: false,
//       requestSoundPermission: false,
//       onDidReceiveLocalNotification:
//           (int id, String title, String body, String payload) async {
//         didReceiveLocalNotificationSubject.add(ReceivedNotification(
//             id: id, title: title, body: body, payload: payload));
//       });
//   var initializationSettings = InitializationSettings(
//       initializationSettingsAndroid, initializationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onSelectNotification: (String payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: ' + payload);
//     }
//     selectNotificationSubject.add(payload);
//   });
// }

// Future<void> showNotification(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       '0', 'Natalia', 'your channel description',
//       importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
//   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       0, 'Natalia title', 'plain body', platformChannelSpecifics,
//       payload: 'item x');
// }

// Future<void> turnOffNotification(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   await flutterLocalNotificationsPlugin.cancelAll();
// }

// Future<void> turnOffNotificationById(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//     num id) async {
//   await flutterLocalNotificationsPlugin.cancel(id);
// }

// Future<void> scheduleNotification(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//     String id,
//     String body,
//     DateTime scheduledNotificationDateTime) async {
//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     id,
//     'Reminder notifications',
//     'Remember about it',
//     icon: 'app_icon',
//   );
//   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.schedule(0, 'Reminder', body,
//       scheduledNotificationDateTime, platformChannelSpecifics);
// }

// Future<void> scheduleNotificationPeriodically(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
//     String id,
//     String body,
//     RepeatInterval interval) async {
//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     id,
//     'Reminder notifications',
//     'Remember about it',
//     icon: 'smile_icon',
//   );
//   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//       androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.periodicallyShow(
//       0, 'Reminder', body, interval, platformChannelSpecifics);
// }

// void requestIOSPermissions(
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
//   flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
// }
