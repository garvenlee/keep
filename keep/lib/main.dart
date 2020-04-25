import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:keep/utils/connectivity_service.dart';
import 'package:keep/utils/sputil.dart';
import 'package:keep/utils/routes.dart';
import 'package:keep/global/connectivity_status.dart';
import 'package:keep/global/notification.dart';
import 'package:keep/UI/Login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  myRunApp(); // sync sharedpreference
  // app statusBar style
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blue[300],
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // local notification settings
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('login_logo');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
  runApp(MyApp());
}

// 同步
void myRunApp() async {
  await SpUtil.getInstance();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/screen2.jpg"), context);
    return StreamProvider<ConnectivityStatus>(
        builder: (context) => ConnectivityService().connectionStatusController,
        child: ChangeNotifierProvider(
            builder: (context) => UserProvider(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Keep Note',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              onGenerateRoute: (settings) {
                MaterialPageRoute nextRoute;
                switch (settings.name) {
                  case '/hold-login':
                    {
                      var data = settings.arguments as Map<String, String>;
                      print(data['email']);
                      nextRoute = MaterialPageRoute(
                          builder: (_) => LoginScreen(data['email']));
                    }
                    break;
                }
                return nextRoute;
              },
              initialRoute: '/',
              routes: routes,
            )));
  }
}
