import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep/data/provider/message_provider.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/repository/message_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:animated_size_and_fade/animated_size_and_fade.dart';

import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/global/connectivity_status.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/global/indicator_num.dart';
import 'package:keep/models/message.dart';
import 'select_edit_page.dart';

class MessageView extends StatefulWidget {
  @override
  _MessageViewState createState() => new _MessageViewState();
}

class _MessageViewState extends State with TickerProviderStateMixin {
  final SlidableController slidableController = new SlidableController();
  // message Repository
  final msgRepo = new MessageRepository();

  BuildContext _ctx;
  var connectionStatus;

  Future<Map<int, List<Message>>> getMessages() async {
    return msgRepo.getAllMessages();
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    return Consumer<UserProvider>(builder: (context, user, child) {
      return new Scaffold(
        body: Column(children: <Widget>[
          _buildStatusBanner(),
          FutureBuilder(
            future: getMessages(),
            builder: (BuildContext context,
                AsyncSnapshot<Map<int, List<Message>>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('awaiting begin sink data......');
                case ConnectionState.waiting:
                  print('awaiting result.......');
                  return Text('awaiting result......');
                default:
                  if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Text(snapshot.error.toString());
                  } else if (snapshot.hasData && snapshot.data.length > 0) {
                    print('there has data');
                    Map<int, List<Message>> _messages = snapshot.data;
                    List<int> _toUserId = [];
                    List<String> _toUsername = [];
                    // print(snapshot.data.keys.runtimeType);
                    _messages.forEach((key, _) {
                      _toUserId.add(key);
                      _toUsername.add(FriendProvider.getUsername(key));
                    });
                    return _buildListView(
                        messages: _messages,
                        toUserId: _toUserId,
                        toUsername: _toUsername,
                        username: user.username);
                  } else {
                    print('there has offline data');
                    List<Message> allMsgs =
                        MessageProvider.getMessages() ?? <Message>[];
                    Map<int, List<Message>> _messages = {};
                    List<int> _toUserId = [];
                    List<String> _toUsername = [];
                    allMsgs.forEach((msg) {
                      if (_messages[msg.recipientId] == null) {
                        _messages[msg.recipientId] = <Message>[];
                        _toUserId.add(msg.recipientId);
                        _toUsername
                            .add(FriendProvider.getUsername(msg.recipientId));
                      }
                      _messages[msg.recipientId].add(msg);
                    });
                    return _buildListView(
                        messages: _messages,
                        toUserId: _toUserId,
                        toUsername: _toUsername,
                        username: user.username,
                        isOffline: true);
                  }
              }
            },
          ),
        ]),
        floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.blueAccent.withOpacity(0.7),
          onPressed: () =>
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return EditSelectPage();
          })),
          tooltip: 'Add contact',
          child: new Icon(Icons.edit),
        ),
      );
    });
  }

  _showSnackBar(val) {
    print(val);
  }

  Widget _buildStatusBanner() {
    String status;
    switch (connectionStatus) {
      case ConnectivityStatus.Available:
        status = 'active';
        break;
      case ConnectivityStatus.Unavailable:
        status = 'inactive';
        break;
      case ConnectivityStatus.Offline:
        status = 'offline';
        break;
      default:
        status = 'offline';
    }
    return AnimatedSizeAndFade.showHide(
        vsync: this,
        show: status != 'active',
        child: status != 'active'
            ? Container(
                height: 28.0,
                width: MediaQuery.of(_ctx).size.width,
                color: statusColor[status],
                child: Center(
                    child: Text(
                  statusIndicator[status],
                  style: TextStyle(
                    fontSize: 16.0,
                    color: statusTextColor[status],
                    decoration: TextDecoration.none,
                  ),
                )),
              )
            : Container());
  }

  buildMsgItem(
      {List<Message> messages,
      String username,
      String toUsername,
      int toUserId,
      bool isOffline}) {
    print('building chat item.................');
    print(messages);
    int tailId = messages.length - 1;
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                if (!isOffline) {
                  return new ChatScreen(
                      username: username,
                      toUsername: toUsername,
                      onlineMessage: messages ?? <Message>[],
                      offlineMessage: <Message>[],
                      toUserId: toUserId);
                } else {
                  return new ChatScreen(
                      username: username,
                      toUsername: toUsername,
                      onlineMessage: <Message>[],
                      offlineMessage: messages ?? <Message>[],
                      toUserId: toUserId);
                }
              }));
            },
            leading: CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.indigoAccent,
              child: Text('g'.toUpperCase()),
              foregroundColor: Colors.white,
            ),
            title: Text(capitalize(toUsername)),
            subtitle: Text(messages[tailId].messageBody.length > 10
                ? messages[tailId].messageBody.substring(0, 10)
                : messages[tailId].messageBody),
            trailing: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(DateFormat('HH:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              messages[tailId].createAt))),
                      buildNumIndicator(messages.length, isOffline),
                    ]))),
      ),
      // actions：前置slidabel
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Sticky',
          color: Color(0xFF61ab32),
          icon: Icons.vertical_align_top,
          onTap: () => _showSnackBar('More'),
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _showSnackBar('Delete'),
        ),
      ],
    );
  }

  _buildListView(
      {Map<int, List<Message>> messages,
      String username,
      List<String> toUsername,
      List<int> toUserId,
      bool isOffline = false}) {
    return Expanded(
        child: ListView.builder(
      shrinkWrap: true,
      padding: new EdgeInsets.all(5.0),
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        // print(index);
        int _toUserId = toUserId[index];
        List<Message> toUserMessage = messages[_toUserId];
        String _toUsername = toUsername[index];
        return buildMsgItem(
            messages: toUserMessage,
            username: username,
            toUsername: _toUsername,
            toUserId: _toUserId,
            isOffline: isOffline);
      },
    ));
  }
}
