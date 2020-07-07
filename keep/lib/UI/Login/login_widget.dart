import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keep/settings/styles.dart' show UserEntranceTextStyle;

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
      height: ScreenUtil.screenHeight * 0.1,
      width: ScreenUtil.screenHeight * 0.1,
      decoration: ShapeDecoration(
          image:
              DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(32.w))),
    );
  }
}

Widget widgetLabelTxt() {
  return Text("Login",
      textScaleFactor: 1.5,
      style: UserEntranceTextStyle.headerLoginLabelTextStyle);
}

class WidgetLoginViaSocialMedia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.only(left: 16, top: 16.0, right: 16.0),
      padding: EdgeInsets.only(top: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white54,
              // color: Colors.purple,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(
              FontAwesomeIcons.google,
              size: 42.w,
              color: Colors.black54,
              // color: Colors.pinkAccent,
            ),
          ),
          SizedBox(width: 84.w),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white54,
              // color: Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(
              FontAwesomeIcons.weixin,
              size: 42.w,
              color: Colors.black54,
              // color: Colors.green,
            ),
          ),
          SizedBox(width: 84.w),
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white54,
              // color: Colors.purple,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Icon(
              FontAwesomeIcons.facebookF,
              size: 42.w,
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
    return Container(
      margin: EdgeInsets.only(top: 128.h),
      child: Center(
        child: Text(
          'Continue with',
          style: UserEntranceTextStyle.headerLoginLabelTextStyle,
        ),
      ),
    );
  }
}

Widget widgetStatusLogin(bool trigger, String hintTxt) {
  if (trigger) {
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
                  Radius.circular(28.w),
                ),
              ),
              padding: EdgeInsets.all(48.w),
              child: Column(
                children: <Widget>[
                  Platform.isIOS
                      ? CupertinoActivityIndicator()
                      : CircularProgressIndicator(),
                  SizedBox(height: 36.h),
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
