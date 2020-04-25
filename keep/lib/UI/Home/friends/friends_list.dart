import 'package:flutter/material.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/models/message.dart';
import 'package:keep/global/user_pic.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => new _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Friend> _friends = [];
  final msgRepo = new MessageRepository();

  @override
  void initState() {
    print('load friends......');
    _friends = FriendProvider.getFriends();
    super.initState();
  }

  Future<Map<int, List<Message>>> getMessages(int recipientId) async {
    return msgRepo.getAllMessages(
        whereString: 'recipient_id = ?', query: recipientId.toString());
  }

  Widget buildChatPage({Friend friend, String username}) {
    return FutureBuilder<Map<int, List<Message>>>(
      future: getMessages(friend.userId),
      builder: (BuildContext context,
          AsyncSnapshot<Map<int, List<Message>>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('awaiting begin sink data......');
          case ConnectionState.waiting:
            print('awaiting result.......');
            return Text('awaiting result......');
          default:
            List<Message> messages;
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Text(snapshot.error.toString());
            } else if (snapshot.hasData &&
                snapshot.data[friend.userId].length > 0) {
              print(snapshot.data);
              messages = snapshot.data[friend.userId];
            } else {
              print('there has no data');
              messages = <Message>[];
            }
            return ChatScreen(
              userType: 1,
              username: username,
              toUsername: friend.username,
              onlineMessage: messages,
              offlineMessage: <Message>[],
              toUserId: friend.userId,
            );
        }
      },
    );
  }

  Widget _buildFriendListTile(
      BuildContext context, int index, String username) {
    var friend = _friends[index];
    return new ListTile(
      onTap: () =>
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        // print(friend.username);
        return buildChatPage(friend: friend, username: username);
      })),
      leading: new Hero(
          tag: index,
          child: friend.avatar != 'null'
              ? CircleAvatar(backgroundImage: friend.avatar)
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
    return Consumer<UserProvider>(builder: (context, user, child) {
      Widget content;

      if (_friends.isEmpty) {
        content = new Center(
          child: new CircularProgressIndicator(),
        );
      } else {
        content = new ListView.builder(
          shrinkWrap: true,
          itemCount: _friends.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildFriendListTile(context, index, user.username);
          },
        );
      }
      return content;
    });
  }
}
