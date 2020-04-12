import 'package:flutter/material.dart';
import 'package:keep/utils/user_pic.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/global/indicator_dot.dart';

class UserPanel extends StatefulWidget {
  final String username;
  final String email;
  final String avatar;

  UserPanel(this.username, this.email, this.avatar);

  @override
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  Widget buildUserPic() {
    if (widget.avatar == 'null') {
      return Container(
          // decoration:
          //     BoxDecoration(border: Border.all(color: Colors.red)),
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: normalUserPic(
              username: widget.username,
              picRadius: 32.0,
              fontSize: 24.0,
              fontColor: Colors.purple[500],
              bgColor: Colors.white30));
    } else {
      return Container(
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(
                color: Colors.grey.withAlpha(20), width: 1.0), // 边色与边宽度
            color: Color(0xFF9E9E9E), // 底色
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 0.5,
                offset: Offset(0.3, 0.3),
              )
            ],
          ),
          child: CircleAvatar(
              radius: 32.0, backgroundImage: txt2Image(widget.avatar)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100.0,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          // border: Border.all(color: Colors.red)
        ),
        child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: buildUserPic(),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(capitalize(widget.username),
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600))),
                      buildDotIndicator('active')
                    ],
                  ))
            ]));
  }
}
