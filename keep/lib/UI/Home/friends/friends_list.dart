import 'dart:async';

import 'package:flutter/material.dart';
import '../chat/chatscreen.dart';
import '../../../data/rest_ds.dart';
import '../../../models/friend.dart';

class FriendsList extends StatefulWidget {
  final String email;
  FriendsList(this.email);
  @override
  _FriendsListState createState() => new _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Friend> _friends = [];
  RestDatasource _api = new RestDatasource();
  @override
  void initState() {
    print('load friends......');
    _loadFriends();
    super.initState();
  }

  Future<void> _loadFriends() async {
    print(widget.email);
    _api.getFriends(widget.email).then((friends) => setState(() {
          _friends = friends;
          print('get friends done.');
        }));
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var friend = _friends[index];
    // print(friend.avatar);
    return new ListTile(
      // onTap: () => _navigateToFriendDetails(friend, friend.email),
      onTap: () =>
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        return ChatScreen();
      })),
      leading: new Hero(
          tag: index,
          child: friend.avatar != 'null'
              ? CircleAvatar(
                  // backgroundImage: new NetworkImage(friend.avatar),
                  backgroundImage: friend.avatar)
              : new CircleAvatar(
                  radius: 25.0,
                  child: new Text(
                    friend.name[0],
                    style: TextStyle(color: Colors.redAccent),
                  ),
                )),
      title: new Text(friend.name),
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
