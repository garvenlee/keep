import 'package:flutter/material.dart';
import 'package:keep/UI/Home/myhomepage.dart';
import 'package:keep/UI/Login/login_screen.dart';
import 'package:keep/UI/Register/register.dart';
import 'package:keep/UI/Forget/forget.dart';
import 'package:keep/UI/start_page.dart';

final routes = {
  '/login': (BuildContext context) => new LoginScreen('admin'),
  '/register': (BuildContext context) => new RegisterScreen(),
  '/forget': (BuildContext context) => new ForgetScreen(),
  '/home': (BuildContext context) => new MyHomePage(),
  '/': (BuildContext context) => new StartApp(),
};
