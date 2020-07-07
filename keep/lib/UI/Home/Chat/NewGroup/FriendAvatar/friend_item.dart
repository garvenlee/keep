import 'package:flutter/material.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/widget/user_pic.dart';
import 'package:keep/widget/indicator_num.dart' show buildSelIndicator;

class FriendItem extends StatelessWidget {
  final Friend friend;
  final bool selection;
  const FriendItem({@required this.friend, this.selection = false, key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: Stack(children: [
        new Hero(
            tag: friend.userId,
            child: friend.avatar != 'null'
                ? CircleAvatar(
                  radius: 25.0,
                  backgroundImage: friend.avatar)
                : normalUserPic(
                    username: friend.username,
                    picRadius: 25.0,
                    fontSize: 20.0,
                    fontColor: Colors.white,
                    bgColor: Colors.indigoAccent)),
        Positioned(bottom: 0, right: 0, child: buildSelIndicator(selection))
      ]),
      title: new Text(friend.username),
      subtitle: new Text(friend.email),
    );
  }
}
