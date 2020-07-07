import 'package:flutter/material.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/widget/user_pic.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
// import 'package:keep/utils/event_util.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  final double topPadding;
  FriendsList({@required this.topPadding});

  final msgRepo = new MessageRepository();

  @override
  Widget build(BuildContext context) {
    final friends = FriendProvider.getFriends();
    return Consumer<UserProvider>(builder: (context, user, child) {
      Widget content;

      if (friends.isEmpty) {
        content = Container(
            height: MediaQuery.of(context).size.height - topPadding,
            child: new Center(child: Text('There has not any friends yet!')));
      } else {
        content = new ListView.builder(
          shrinkWrap: true,
          itemCount: friends.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildFriendListTile(context, friends[index]);
          },
        );
      }
      return content;
    });
  }

  Widget buildChatPage({Friend friend}) {
    return FutureBuilder<List<UserMessage>>(
      future: msgRepo.getMessagesByRecvId(1, friend.userId),
      builder:
          (BuildContext context, AsyncSnapshot<List<UserMessage>> snapshot) {
        Widget page;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            page = Container();
            break;
          case ConnectionState.waiting:
            print('awaiting result.......');
            page = Container();
            break;
          default:
            List<UserMessage> messages = <UserMessage>[];
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              page = Container();
            } else if (snapshot.hasData) {
              // print(snapshot.data);
              messages = snapshot.data;
              page = ChatScreen(
                userType: 1,
                friend: friend,
                messages: messages,
              );
            }
        }
        return page;
      },
    );
  }

  Widget _buildFriendListTile(BuildContext context, Friend friend) {
    return new ListTile(
      onTap: () => Navigator.of(context).push(
          new MaterialPageRoute(builder: (_) => buildChatPage(friend: friend))),
      leading: new Hero(
          tag: UniqueKey().toString(),
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
}

// class FriendsList extends StatefulWidget {
//   final double topPadding;
//   FriendsList({@required this.topPadding});
//   @override
//   _FriendsListState createState() => new _FriendsListState();
// }

// class _FriendsListState extends State<FriendsList> {
//   List<Friend> _friends = [];
//   final msgRepo = new MessageRepository();

//   @override
//   void initState() {
//     print('load friends......');
//     _friends = FriendProvider.getFriends();
//     super.initState();
//   }

//   Widget buildChatPage({Friend friend, String username, Object avatar}) {
//     return FutureBuilder<List<UserMessage>>(
//       future: msgRepo.getMessagesByRecvId(1, friend.userId),
//       builder:
//           (BuildContext context, AsyncSnapshot<List<UserMessage>> snapshot) {
//         Widget page;
//         switch (snapshot.connectionState) {
//           case ConnectionState.none:
//             // return Text('awaiting begin sink data......');
//             page = Container();
//             break;
//           case ConnectionState.waiting:
//             print('awaiting result.......');
//             // return Text('awaiting result......');
//             page = Container();
//             break;
//           default:
//             List<UserMessage> messages = <UserMessage>[];
//             if (snapshot.hasError) {
//               print(snapshot.error.toString());
//               // return Text(snapshot.error.toString());
//               page = Container();
//             } else if (snapshot.hasData) {
//               print(snapshot.data);
//               messages = snapshot.data;
//               page = ChatScreen(
//                 userType: 1,
//                 // username: username,
//                 // avatar: avatar,
//                 friend: friend,
//                 messages: messages,
//               );
//             }
//         }
//         return page;
//       },
//     );
//   }

//   Widget _buildFriendListTile(
//       BuildContext context, int index, String username, Object avatar) {
//     var friend = _friends[index];
//     return new ListTile(
//       onTap: () async {
//         final result = await Navigator.of(context)
//             .push(new MaterialPageRoute(builder: (_) {
//           // print(friend.username);
//           return buildChatPage(
//               friend: friend, username: username, avatar: avatar);
//         }));
//         if (result) bus.emit('scratchAllMessages', true);
//       },
//       leading: new Hero(
//           tag: index,
//           child: friend.avatar != 'null'
//               ? CircleAvatar(backgroundImage: friend.avatar)
//               : normalUserPic(
//                   username: friend.username,
//                   picRadius: 25.0,
//                   fontSize: 20.0,
//                   fontColor: Colors.white,
//                   bgColor: Colors.indigoAccent)),
//       title: new Text(friend.username),
//       subtitle: new Text(friend.email),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<UserProvider>(builder: (context, user, child) {
//       Widget content;

//       if (_friends.isEmpty) {
//         content = Container(
//             height: MediaQuery.of(context).size.height - widget.topPadding,
//             child: new Center(
//                 // child: new CircularProgressIndicator(),
//                 child: Text('There has not any friends yet!')));
//       } else {
//         content = new ListView.builder(
//           shrinkWrap: true,
//           itemCount: _friends.length,
//           itemBuilder: (BuildContext context, int index) {
//             return _buildFriendListTile(
//                 context, index, user.username, user.userAvatar);
//           },
//         );
//       }
//       return content;
//     });
//   }
// }
