import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserPic extends StatefulWidget {
  UserPic({Key key}) : super(key: key);

  @override
  _UserPicState createState() => _UserPicState();
}

class _UserPicState extends State<UserPic> {
  @override
  Widget build(BuildContext context) {
    return ovalImage('assets/images/user_logo.jpeg');
  }

  Widget ovalImage(String imagePath) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 45.0, 0, 10.0),
      decoration: ShapeDecoration(
          image:
              DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(20))),
      width: 90,
      height: 90,
    );
  }
}

Widget buildSpace(BuildContext context) {
  return new SizedBox.fromSize(
    child: Container(
      height: MediaQuery.of(context).size.height * 0.04,
      // color: Colors.white,
    ),
  );
}

Widget widgetLabelTxt() {
  return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 45.0),
      child: Text("Login",
          textScaleFactor: 1.5, style: TextStyle(color: Colors.white70)));
}

class WidgetLoginViaSocialMedia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white54,
              // color: Colors.purple,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Icon(
              FontAwesomeIcons.google,
              size: 18.0,
              color: Colors.black54,
              // color: Colors.pinkAccent,
            ),
          ),
          SizedBox(width: 32.0),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white54,
              // color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Icon(
              FontAwesomeIcons.weixin,
              size: 18.0,
              color: Colors.black54,
              // color: Colors.green,
            ),
          ),
          SizedBox(width: 32.0),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white54,
              // color: Colors.purple,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Icon(
              FontAwesomeIcons.facebookF,
              size: 18.0,
              // color: Colors.blue,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class WidgetLabelContinueWith extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48.0),
      child: Center(
        child: Text(
          'Continue with',
          style: TextStyle(color: Colors.white70, fontSize: 16.0),
        ),
      ),
    );
  }
}

Widget widgetStatusLogin(bool triger, String hintTxt) {
  if (triger) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: Wrap(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Platform.isIOS
                      ? CupertinoActivityIndicator()
                      : CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text(hintTxt),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  } else {
    return Container();
  }
}
