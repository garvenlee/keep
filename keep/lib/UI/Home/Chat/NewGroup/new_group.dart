import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

import 'package:keep/models/friend.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'FriendAvatar/sel_friend_avatar.dart';
import 'package:keep/utils/utils_class.dart';
import 'FriendAvatar/friend_item.dart';
import 'package:keep/service/socket_util.dart';
import 'package:keep/models/group.dart';
import 'package:keep/models/group_client.dart';
// import 'package:keep/utils/util_bloc.dart';
import 'package:keep/BLoC/group_client_bloc.dart';
import 'package:keep/BLoC/group_bloc.dart';

class NewGroupPage extends StatefulWidget {
  NewGroupPage({Key key}) : super(key: key);

  @override
  _NewGroupPageState createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  List<Friend> _allFriends = FriendProvider.getFriends();
  List<bool> _selNote = <bool>[];
  List<Friend> _selFriends = <Friend>[];
  List<int> _selFriendsId = <int>[];
  int _selNum = 0;
  String headerText;
  SocketIO _socket;
  BuildContext _ctx;

  final groupBloc = new GroupBloc();
  final clientsBloc = new GroupClientBloc();

  @override
  void dispose() {
    groupBloc.dispose();
    clientsBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _allFriends.length; i++) {
      _selNote.add(false);
    }
    initSocket().then((socket) {
      _socket = socket;
    });
  }

  initSocket() async {
    return await new SocketUtil().socket;
  }

  Future handleCreate(groupProperty, user) async {
    if (groupProperty != null) {
      UploadPopReceiver groupRes = groupProperty as UploadPopReceiver;
      // print(groupRes.stream['groupName']);
      int createAt = DateTime.now().millisecondsSinceEpoch;
      _socket.emit('create', [
        {
          'room_name': groupRes.stream['groupName'],
          'room_avatar': groupRes.stream['groupAvatar'],
          'user_id': user.userId,
          'userIdList': _selFriendsId,
          'timestamp': createAt
        }
      ]);
      // 此处应该再加上请求超时控制，终端连接超时就提示超时
      _socket.on('createSuccess', (res) {
        Map stream = res as Map;
        print(stream);
        if (stream['success'] as bool) {
          // print(stream['room_number']);
          Group group = new Group(
              roomId: stream['room_id'] as int,
              roomNumber: stream['room_number'] as String,
              roomName: groupRes.stream['groupName'],
              roomSize: _selFriendsId.length + 1,
              roomAvatar: groupRes.stream['groupAvatar'],
              userId: user.userId,
              username: user.username,
              email: user.email,
              userAvatar: user.avatar,
              createAt: createAt);
          groupBloc.addGroup(group);
          for (int i = 0; i < _selFriendsId.length; i++) {
            GroupClient client = new GroupClient(
                roomId: stream['room_id'] as int,
                userId: _selFriendsId[i],
                username: _selFriends[i].username,
                email: _selFriends[i].email,
                userAvatar: _selFriends[i].base64Text,
                joinAt: createAt);
            clientsBloc.addMember(client);
          }
          // Navigator.pushNamed(_ctx, 'chatRooms');
        }
        return Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final uid = UserProvider.getUserId();
    _ctx = context;
    return Material(
        child: SafeArea(
            child: Scaffold(
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          buildHeader(context),
          buildMemberRowView(),
          buildBottomLine(),
          buildFriendList(context),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _selNum > 0
          ? Consumer<UserProvider>(builder: (context, user, child) {
              return Padding(
                padding: EdgeInsets.only(bottom: 25.0),
                child: FloatingActionButton(
                  elevation: 5.0,
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/addGroupName',
                            arguments: {"friends": _selFriends})
                        .then((Object groupProperty) =>
                            handleCreate(groupProperty, user))
                        .then((_) => Navigator.pop(_ctx));
                  },
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_forward,
                    size: 32,
                    color: Colors.indigoAccent,
                  ),
                ),
              );
            })
          : null,
    )));
  }

  Widget buildHeader(BuildContext context) {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, _) {
      String headerText;
      if (connectionStatus == ConnectivityStatus.Available)
        headerText = 'Add Group';
      else
        headerText = 'Connecting...';
      return new Container(
          height: 50.0,
          decoration: BoxDecoration(color: Colors.blueGrey),
          padding: new EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Text(headerText,
                      style: TextStyle(
                          // color: Colors.white70,
                          fontSize: 18.0))),
            ],
          ));
    });
  }

  Widget buildMemberRowView() {
    return Container(
        height: 50.0,
        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
        child: _selNum > 0
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 36.0, maxWidth: 36.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _selNum,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          width: 36.0,
                          height: 36.0,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: SelFriendPic(friend: _selFriends[index]));
                    }))
            : Align(
                alignment: Alignment.centerLeft,
                child: Text('Add People...',
                    style: TextStyle(color: Colors.black54, fontSize: 16.0))));
  }

  Widget buildBottomLine() {
    return Container(
        height: 2,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 45.0,
                  offset: Offset(0.0, 0.75))
            ],
            border: Border(
                bottom: BorderSide(width: 1.2, color: Color(0xffe5e5e5)))));
  }

  removeSelection(int index) {
    setState(() {
      _selFriends.removeAt(index);
      _selFriendsId.removeAt(index);
      _selNum -= 1;
      _selNote[index] = false;
    });
  }

  addSelection(int index) {
    setState(() {
      _selFriends.add(_allFriends[index]);
      _selFriendsId.add(_allFriends[index].userId);
      _selNum += 1;
      _selNote[index] = true;
    });
  }

  Widget buildFriendList(BuildContext context) {
    return _allFriends.length > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _allFriends.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    bool addFlag = true;
                    // print(_selFriendsId);
                    for (int i = 0; i < _selNum; i++) {
                      if (_selFriendsId[i] == _allFriends[index].userId) {
                        removeSelection(i);
                        addFlag = false;
                        break;
                      }
                    }
                    if (addFlag) addSelection(index);
                  },
                  child: FriendItem(
                      friend: _allFriends[index], selection: _selNote[index]));
            },
          )
        : Container(
            height: MediaQuery.of(context).size.height - 160,
            child: new Center(
                // child: new CircularProgressIndicator(),
                child: Text('There has not any friends yet!')));
  }
}
