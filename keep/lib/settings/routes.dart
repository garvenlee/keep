import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keep/UI/Home/Chat/ChatRooms/chat_rooms.dart';
import 'package:keep/UI/Home/myhomepage.dart';
import 'package:keep/UI/Login/login_screen.dart';
import 'package:keep/UI/Register/register.dart';
import 'package:keep/UI/Forget/reset.dart';
import 'package:keep/UI/start_page.dart';
// import 'package:keep/UI/Home/Chat/NewGroup/AddGroupName/add_group_name.dart';

final routes = {
  '/': (BuildContext context) => new StartApp(),
  '/login': (BuildContext context) => new LoginScreen('admin'),
  '/register': (BuildContext context) => new RegisterScreen(),
  '/forget': (BuildContext context) => new ForgetScreen(),
  '/home': (BuildContext context) => new MyHomePage(),
  '/chatRooms': (BuildContext context) => new ChatRoomPage()
};
