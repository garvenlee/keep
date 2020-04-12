import 'package:flutter/material.dart';
import 'package:keep/UI/Home/chat/chatscreen.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/utils/sputil.dart';
import 'package:keep/utils/user_pic.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => new _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Friend> _friends = [];
  // RestDatasource _api = new RestDatasource();
  @override
  void initState() {
    print('load friends......');
    _loadFriends();
    super.initState();
  }

  void _loadFriends(){
    setState((){
      _friends = SpUtil.getObjList("friends", Friend.fromMap);
    });
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var friend = _friends[index];
    return new ListTile(
      onTap: () =>
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        return ChatScreen();
      })),
      leading: new Hero(
          tag: index,
          child: friend.avatar != 'null'
              ? CircleAvatar(
                  backgroundImage: friend.avatar)
              : normalUserPic(
                username: friend.username, 
                picRadius: 25.0, 
                fontSize: 20.0,
                fontColor: Colors.white,  
                bgColor: Colors.indigoAccent)),
      title: new Text(friend.username),
      subtitle: new Text(friend.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_friends.isEmpty) {
      content = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      content = new ListView.builder(
        shrinkWrap: true,
        itemCount: _friends.length,
        itemBuilder: _buildFriendListTile,
      );
    }
    return content;
  }
}
