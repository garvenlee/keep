import 'package:flutter/material.dart';
import './Login/login_screen.dart';
import './Home/myhomepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartApp extends StatefulWidget {
  StartApp({Key key}) : super(key: key);

  @override
  _StartAppState createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  var isLogedIn;

  void initState() {
    super.initState();
    _validateLogin();
  }

  @override
  Widget build(BuildContext context) {
    if (isLogedIn == 1) {
      return MyHomePage();
    } else {
      return LoginScreen("admin");
    }
  }

  Future _validateLogin() async {
    Future<dynamic> future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("isLogedIn");
    });
    future.then((val) {
      if (val == null) {
        setState(() {
          isLogedIn = 0;
        });
      } else {
        setState(() {
          isLogedIn = 1;
        });
      }
    }).catchError((_) {
      print("catchError");
    });
  }
}
