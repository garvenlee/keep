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
          capitalize(username[0]),
          style: TextStyle(
            color: fontColor,
            fontSize: fontSize,
          ),
        ),
      ));
}
