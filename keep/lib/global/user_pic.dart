import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:keep/global/global_tool.dart';

MemoryImage txt2Image(String base64Text) {
  var decodeTxt = Base64Decoder().convert(base64Text.split(',')[1]);
  return MemoryImage(decodeTxt);
}

Widget normalUserPic(
    {String username,
    double picRadius,
    double fontSize,
    Color fontColor,
    Color bgColor}) {
  return Container(
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        border: new Border.all(
            color: Colors.grey.withAlpha(20), width: 1.0), // 边色与边宽度
        // color: Color(0xFF9E9E9E), // 底色
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            offset: Offset(0.5, 0.5),
          )
        ],
      ),
      child: CircleAvatar(
        // backgroundColor: Colors.white30,
        backgroundColor: bgColor,
        radius: picRadius,
        child: new Text(
          username != '' ? capitalize(username[0]) : '',
          style: TextStyle(
            color: fontColor,
            fontSize: fontSize,
          ),
        ),
      ));
}

class UserAvatar extends StatelessWidget {
  final String username;
  final String avatar;
  UserAvatar(this.username, this.avatar);

  @override
  Widget build(BuildContext context) {
    if (this.avatar == 'null') {
      return Container(
          // decoration:
          //     BoxDecoration(border: Border.all(color: Colors.red)),
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: normalUserPic(
              username: this.username,
              picRadius: 30.0,
              fontSize: 20.0,
              fontColor: Colors.white,
              bgColor: Colors.indigoAccent));
    } else {
      var avatar = txt2Image(this.avatar);
      return Container(
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(
                color: Colors.white.withAlpha(100), width: 1), // 边色与边宽度
            color: Color(0xFF9E9E9E), // 底色
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: CircleAvatar(radius: 30.0, backgroundImage: avatar));
    }
  }
}
