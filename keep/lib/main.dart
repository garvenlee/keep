import 'package:flutter/material.dart';
// import 'package:keep/UI/Home/myhomepage.dart';
// import 'package:keep/UI/Home/home_screen.dart';
// import 'package:keep/UI/entrance.dart';
// import './models/user.dart';
import 'package:keep/utils/routes.dart';
import 'package:keep/UI/Login/login_screen.dart';

void main() {
  runApp(MyApp());
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
