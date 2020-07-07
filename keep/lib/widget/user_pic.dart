import 'package:flutter/material.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            color: Colors.grey.withAlpha(20), width: 1.w), // 边色与边宽度
        // color: Color(0xFF9E9E9E), // 底色
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.w,
            offset: Offset(0.5.w, 0.5.h),
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
  final Object avatar;
  UserAvatar(this.username, this.avatar);

  @override
  Widget build(BuildContext context) {
    if (this.avatar == 'null') {
      return Container(
          // decoration:
          //     BoxDecoration(border: Border.all(color: Colors.red)),
          padding: EdgeInsets.symmetric(vertical: 36.h),
          child: normalUserPic(
              username: this.username,
              picRadius: 84.w,
              fontSize: 48.sp,
              fontColor: Colors.white,
              bgColor: Colors.indigoAccent));
    } else {
      // var avatar = txt2Image(this.avatar);
      return Container(
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(
                color: Colors.white.withAlpha(100), width: 1.w), // 边色与边宽度
            color: Color(0xFF9E9E9E), // 底色
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.w,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 36.h),
          child: CircleAvatar(radius: 84.w, backgroundImage: this.avatar));
    }
  }
}
