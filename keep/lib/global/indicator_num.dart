import 'package:flutter/material.dart';

var bgColor = {'offline': Colors.grey, 'online': const Color(0xFFf46464)};

Widget buildNumIndicator(int length, bool isOffline) {
  return new CircleAvatar(
    radius: 10,
    backgroundColor: isOffline ? bgColor['offline'] : bgColor['online'],
    child: Text(
      length > 99 ? '99+' : length.toString(),
      style: TextStyle(fontSize: 10.0),
    ),
    foregroundColor: Colors.white,
  );
}
