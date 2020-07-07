import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:keep/settings/status_config.dart';


Widget showFlushBar(BuildContext context, String username, String text, int id) {
    // print(text);
    return Flushbar(
      title: "Hey, " + username,
      message: text,
      // messageText: Container(),
      duration: Duration(seconds: 1),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      // backgroundColor: Colors.redAccent,
      boxShadows: [
        BoxShadow(color: Colors.grey, offset: Offset(0.0, 1.0), blurRadius: 1.0)
      ],
      backgroundGradient:
          LinearGradient(colors: [Colors.blueGrey, Colors.black]),
      isDismissible: false,
      icon: iconLists[id],
      mainButton: FlatButton(
        onPressed: () {},
        child: Text(
          "CLAP",
          style: TextStyle(color: Colors.amber),
        ),
      ),
      // showProgressIndicator: true,
      // progressIndicatorBackgroundColor: Colors.blueGrey,
    )..show(context);
  }