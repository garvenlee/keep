import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep/utils/sputil.dart';
import 'package:keep/utils/routes.dart';
import 'package:keep/UI/Login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  myRunApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.blue[300],
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(MyApp());
}

void myRunApp() async {
  await SpUtil.getInstance();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Keep Note',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/hold-login':
            {
              var data = settings.arguments as Map<String, String>;
              print(data['email']);
              return MaterialPageRoute(
                  builder: (_) => LoginScreen(data['email']));
            }
            break;
        }
      },
      initialRoute: '/',
      routes: routes,
    );
  }
}
