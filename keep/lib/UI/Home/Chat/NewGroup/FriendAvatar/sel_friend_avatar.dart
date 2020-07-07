import 'package:flutter/material.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/widget/user_pic.dart';

class SelFriendPic extends StatelessWidget {
  final Friend friend;
  const SelFriendPic({@required this.friend, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Hero(
          tag: -friend.userId,
          child: friend.avatar != 'null'
              ? Container(
                  // height: 36.0,
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
                      radius: 18.0, backgroundImage: friend.avatar))
              : normalUserPic(
                  username: friend.username,
                  picRadius: 18.0,
                  fontSize: 16.0,
                  fontColor: Colors.white,
                  bgColor: Colors.indigoAccent),
    );
  }
}
