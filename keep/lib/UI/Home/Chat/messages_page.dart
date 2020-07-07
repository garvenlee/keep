import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:keep/BLoC_provider/bloc_provider.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:keep/widget/indicator_num.dart';
import 'package:keep/widget/over_scroll.dart';
import 'package:provider/provider.dart';
import 'package:keep/data/provider/user_provider.dart';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';

import 'package:keep/settings/status_config.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
// import 'package:keep/utils/event_util.dart';
import 'package:keep/BLoC/message_bloc.dart';

import 'package:keep/models/message.dart';
import 'ChatScreenUI/chatscreen.dart';
import 'select_edit_page.dart';

const OneDayMillionSeconds = 24 * 60 * 60 * 1000;

class MessageView extends StatefulWidget {
  const MessageView({Key key}) : super(key: key);
  @override
  _MessageViewState createState() => new _MessageViewState();
}

class _MessageViewState extends State with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Column(children: <Widget>[buildStatusBanner(), MessageList()]),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: new FloatingActionButton(
            backgroundColor: Colors.blueAccent.withOpacity(0.7),
            onPressed: () =>
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return EditSelectPage();
            })),
            tooltip: 'Add contact',
            child: new Icon(Icons.edit),
          ),
        ));
  }

  Widget buildStatusBanner() {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, _) {
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
                  width: MediaQuery.of(context).size.width,
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
    });
  }
}

class MessageList extends StatelessWidget {
  final msgBloc = MessageBloc();
  final DismissDirection _dismissDirection = DismissDirection.horizontal;
  @override
  Widget build(BuildContext context) {
    // final msgBloc = BlocProvider.of<MessageBloc>(context);
    return Provider(
        create: (context) => msgBloc,
        dispose: (context, bloc) => bloc.dispose(),
        child: Consumer<UserProvider>(
            builder: (context, user, child) => StreamBuilder(
                stream: msgBloc.messages,
                builder: (contetx, snapshot) => snapshot.hasData
                    ? buildMessageList(
                        snapshot.data, user.username, user.userAvatar, msgBloc)
                    : Container())));
  }

  Widget buildMessageList(List<Message> messages, String username,
      Object userAvatar, MessageBloc msgBloc) {
    debugPrint('update the whole list view....');
    return Expanded(
        child: ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                final Message msg = messages[index];
                final String name = msg.name;
                final Object avatar = msg.avatar;
                final int tailId = msg.messages.length - 1;
                final bool isOffline = msg.offlineFlag;
                final int msgHintNum =
                    isOffline ? msg.offlineMsgNum : msg.msgHintNum;
                return Dismissible(
                  key: UniqueKey(),
                  direction: _dismissDirection,
                  background: Container(
                      color: Colors.redAccent,
                      padding: EdgeInsets.only(left: 10, right: 10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.delete),
                            Text("Delete",
                                style: TextStyle(color: Colors.white))
                          ])),
                  onDismissed: (_) => msgBloc.deleteMessages(msg.messages),
                  child: ListTile(
                      onTap: () {
                        Navigator.of(context)
                            .push(new MaterialPageRoute(builder: (context) {
                          return new ChatScreen(
                              userType: msg.chatType,
                              friend: msg.friend,
                              group: msg.group,
                              members: msg.members,
                              messages: msg.messages);
                        }));
                      },
                      leading: avatar != 'null'
                          ? CircleAvatar(radius: 24.0, backgroundImage: avatar)
                          : CircleAvatar(
                              radius: 24.0,
                              backgroundColor: Colors.indigoAccent,
                              child: Text(name[0].toUpperCase()),
                              foregroundColor: Colors.white,
                            ),
                      title: Text(capitalize(name)),
                      subtitle: Text(msg.messages[tailId].messageBody,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Container(
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                buildTimestamp(msg.messages[tailId].createAt),
                                if (msgHintNum > 0)
                                  buildNumIndicator(msgHintNum, isOffline),
                              ]))),
                );
              },
            )));
  }

  Widget buildTimestamp(int createAt) {
    final nowTime = DateTime.now().millisecondsSinceEpoch;
    final int interval = nowTime - createAt;
    if (interval < OneDayMillionSeconds)
      return new Text(DateFormat('HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(createAt)));
    else if (interval < 2 * OneDayMillionSeconds)
      return new Text('Yesterday');
    else
      return new Text(DateFormat('dd MMM')
          .format(DateTime.fromMillisecondsSinceEpoch(createAt)));
  }
}
