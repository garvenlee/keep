import 'package:flutter/material.dart';

Widget buildGap() {
  return Container(
      height: 15,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border(
            top: BorderSide(width: 1, color: Color(0xffe5e5e5)),
            bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)),
          )));
}

Widget buildBottom() {
  return Container(
      height: 0.5,
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)))));
}

Widget buildItem(Icon icon, String heading, String tail, Function callback) {
  return Container(
      child: ListTile(
    leading: icon,
    title: Text(
      heading,
      style: TextStyle(color: Colors.grey),
    ),
    trailing: Text(
      tail,
      style: TextStyle(fontSize: 16.0),
    ),
    onTap: () {},
  ));
}
