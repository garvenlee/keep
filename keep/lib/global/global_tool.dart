import 'package:flutter/material.dart';

// Text Style
final entranceStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 15.0);

// statusBar
final List<Icon> iconLists = [
  Icon(
    Icons.check,
    color: Colors.greenAccent,
  ),
  Icon(
    Icons.error_outline,
    color: Colors.greenAccent,
  )
];
final iconIndicator = {"success": 0, "error": 1};

// form validate
final RegExp emailReg =
    new RegExp(r'^[A-Za-z0-9]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
final RegExp codeReg = new RegExp(r'[0-9]{6}');

String judgePwd(String val) {
  if (val.isEmpty) {
    return "password cannot be empty!";
  } else if (val.length < 8) {
    return "must be at least 8 characters!";
  } else if (val.length > 15) {
    return "must be at most 15 characters!";
  } else {
    return null;
  }
}

String judgeEmail(String val) {
  if (val.isEmpty) return "email don't be empty!";
  return !emailReg.hasMatch(val) ? "Please check the email's format" : null;
}

String judgeCode(String val) {
  if (val.isEmpty) {
    return "code cannot be empty!";
  }
  if (!(val.length == 6)) {
    return "length must be 6";
  } else {
    return !codeReg.hasMatch(val) ? "no character in code!" : null;
  }
}

String capitalize(String input) {
  return input.substring(0, 1).toUpperCase() + input.substring(1);
}

class UploadPopReceiver {
  Map<String, dynamic> stream;
  UploadPopReceiver(this.stream);
}

class UpgradeUserPic{
  Map<String, dynamic> stream;
  UpgradeUserPic(this.stream);
}
