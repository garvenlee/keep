import 'package:flutter/material.dart';
import 'package:keep/utils/sputil.dart';
import 'Login/login_screen.dart';
import 'Home/myhomepage.dart';

class StartApp extends StatefulWidget {
  StartApp({Key key}) : super(key: key);

  @override
  _StartAppState createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  var isLogedIn;

  void initState() {
    super.initState();
    setState(() {
      isLogedIn = SpUtil.getString('isLogedIn');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogedIn == 'LogedIn') {
      return MyHomePage();
    } else {
      return LoginScreen("admin");
    }
  }
}
