import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'Home/myhomepage.dart';
import 'Login/login_screen.dart';

class StartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, user, child) {
      return user.isLogedIn ? MyHomePage() : LoginScreen(user.email);
    });
  }
}
