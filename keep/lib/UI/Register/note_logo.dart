import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keep/settings/styles.dart';

class WidgetIconNoting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 256.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              height: 256.h,
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/login_logo.jpg',
                    height: 128.h,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              )),
          SizedBox(width: 64.w),
          Text('Keep App',
            style: UserEntranceTextStyle.headerRegisterLabelTextStyle
          ),
        ],
      ),
    );
  }
}
