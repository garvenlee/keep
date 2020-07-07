import 'package:flutter/material.dart';
import 'package:keep/widget/over_scroll.dart';
import 'package:keep/models/group_client.dart';
// import 'package:keep/utils/event_util.dart';
// import 'package:keep/utils/util_bloc.dart';
import 'package:keep/BLoC/group_bloc.dart';

import 'package:provider/provider.dart';
import 'package:keep/models/group.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/widget/user_pic.dart';
import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/data/repository/group_client_repository.dart';

class RoomsList extends StatelessWidget {
  final double topPadding;
  RoomsList({@required this.topPadding});

  final msgRepo = new MessageRepository();
  final clientsRepo = new GroupClientRepository();
  final groupBloc = new GroupBloc();

  Future<List<UserMessage>> getMessages(int recipientGroupId) async {
    return msgRepo.getMessagesByRecvId(2, recipientGroupId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, user, child) {
          return Provider(
              create: (context) => groupBloc,
              dispose: (context, bloc) => bloc.dispose(),
              child: StreamBuilder(
                  stream: groupBloc.groups,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Group>> snapshot) {
                    List<Group> groups = snapshot.data;
                    // print('groups length =============> ${groups.length}');
                    final hasGroups = groups?.isNotEmpty == true;
                    return hasGroups
                        ? buildRoomList(groups, user.username, user.userAvatar)
                        : child;
                  }));
        },
        child: buildNoRoomWidget(context));
  }

  Widget buildRoomList(List<Group> groups, String username, Object avatar) {
    return Material(
        child: ScrollConfiguration(
            behavior: OverScrollBehavior(),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder(
                    future:
                        clientsRepo.getGroupClientsById(groups[index].roomId),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<GroupClient>> snapshot) {
                      Widget page;
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          // return Text('awaiting begin sink data......');
                          page = Container();
                          break;
                        case ConnectionState.waiting:
                          print('awaiting result.......');
                          page = Container();
                          // return Text('awaiting result......');
                          break;
                        default:
                          if (snapshot.hasError) {
                            print(snapshot.error.toString());
                            page = Container();
                          } else if (snapshot.hasData) {
                            // print(snapshot.data);
                            List<GroupClient> clients = snapshot.data;
                            Map<int, GroupClient> members = {};
                            clients.forEach(
                                (client) => members[client.userId] = client);
                            page = buildRoomItem(context, groups[index],
                                username, avatar, members);
                          }
                      }
                      return page;
                    },
                  );
                })));
  }

  Widget buildNoRoomWidget(context) {
    return Container(
        height: MediaQuery.of(context).size.height - 80.0,
        child: new Center(
            // child: new CircularProgressIndicator(),
            child: Text('There has not any groups yet!')));
  }

  Widget buildChatPage(
      {Group group,
      String username,
      Object avatar,
      Map<int, GroupClient> members}) {
    return FutureBuilder<List<UserMessage>>(
      future: getMessages(group.roomId),
      builder:
          (BuildContext context, AsyncSnapshot<List<UserMessage>> snapshot) {
        Widget page;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // return Text('awaiting begin sink data......');
            page = Container();
            break;
          case ConnectionState.waiting:
            print('awaiting result.......');
            page = Container();
            // return Text('awaiting result......');
            break;
          default:
            List<UserMessage> messages = <UserMessage>[];
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              page = Container();
            } else if (snapshot.hasData) {
              print(snapshot.data);
              messages.addAll(snapshot.data);
              page = ChatScreen(
                userType: 2,
                // username: username,
                // avatar: avatar,
                group: group,
                messages: messages,
                members: members,
              );
            }
        }
        return page;
      },
    );
  }

  Widget buildRoomItem(BuildContext context, Group group, String username,
      Object avatar, Map<int, GroupClient> members) {
    return new ListTile(
      onTap: () =>
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        return buildChatPage(
            group: group, username: username, avatar: avatar, members: members);
      })),
      // if (result) bus.emit('scratchAllMessages', true);
      leading: new Hero(
          tag: group.roomId,
          child: group.roomAvatar != 'null'
              ? CircleAvatar(backgroundImage: group.roomAvatarObj)
              : normalUserPic(
                  username: group.roomName,
                  picRadius: 25.0,
                  fontSize: 20.0,
                  fontColor: Colors.white,
                  bgColor: Colors.indigoAccent)),
      title: new Text(group.roomName),
      subtitle: new Text(group.roomNumber),
    );
  }
}
