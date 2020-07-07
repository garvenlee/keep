import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:provider/provider.dart';
import 'package:after_layout/after_layout.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:keep/service/socket_util.dart';

import 'package:keep/data/sputil.dart';
import 'package:keep/data/provider/badgeNum_provider.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/BLoC/message_bloc.dart';

import 'package:keep/models/friend.dart';

import 'package:keep/utils/event_util.dart';
import 'package:keep/utils/tools_function.dart';

import 'package:keep/settings/notification_helper.dart';

import 'nav_drawer.dart';
import 'package:keep/widget/over_scroll.dart';
import 'package:keep/widget/storage_panel_widget.dart';
import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
import 'package:keep/UI/Home/chat/messages_page.dart';
import 'package:keep/UI/Home/Noting/note_page.dart';
import 'package:keep/UI/Home/Todo/todo_page.dart' show TodoPage;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, AfterLayoutMixin<MyHomePage> {
  final _kTabPages = <Widget>[
    Center(child: NotePage()),
    Center(child: TodoPage()),
    Center(child: MessageView()),
  ];
  TabController _tabController;
  final String username = UserProvider().username;
  final Object avatar = UserProvider().userAvatar;
  final userId = UserProvider.getUserId();
  final apiKey = UserProvider.getApiKey();
  final msgRepo = new MessageRepository();
  final msgBloc = new MessageBloc();

  final _textController = new TextEditingController();

  // notification
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');

  BuildContext _ctx;

  static const textStyle = TextStyle(
      fontSize: 12.0,
      color: Colors.white,
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w600);
  SocketIO _socket;

  initSocket() async {
    return await new SocketUtil().socket;
  }

  void msgStreamCallback() => msgBloc.getMessages();

  @override
  void initState() {
    super.initState();

    int initialIndex = SpUtil.getInt('$userId-initialIndex', defValue: 1);
    _tabController =
        new TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(
        () => SpUtil.putInt('$userId-initialIndex', _tabController.index));
    // _requestIOSPermissions();
    // _configNotification();
    _configureSelectNotificationSubject();
    _configureDidReceiveLocalNotificationSubject();
  }

  void onChat(stream) {
    print('listen...');
    stream['context'] = context;
    onChatCallback(stream);
  }

  void onChats(stream) {
    stream['context'] = context;
    onChatsCallback(stream);
  }

  void onFriendRequest(stream) {
    stream['context'] = context;
    onFriendRequestCallback(stream);
  }

  void onFriendsRequest(stream) {
    stream['context'] = context;
    onFriendsRequestCallback(stream);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    initSocket().then((socket) {
      _socket = socket;
      _socket.on('chat', onChat);
      _socket.on('chats', onChats);
      _socket.on('friendRequest', onFriendRequest);
      _socket.on('friendRequests', onFriendsRequest);
      _socket.connect();
    });
  }

  @override
  void dispose() {
    _socket.off('chat');
    _socket.off('chats');
    _socket.off('friendRequest');
    _socket.off('friendRequests');
    bus.off('scratchAllMessages', (_) => msgStreamCallback);
    _tabController.dispose();
    flutterLocalNotificationsPlugin.cancelAll();
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();

    msgBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('loading tab view page....');
    _ctx = context;
    precacheImage(AssetImage("assets/images/nav_me.jpg"), context);
    bus.on('scratchAllMessages', (_) => msgStreamCallback);
    // bus.on('triggerMsgNotification', (stream) => onChatCallback(stream));
    return Material(
        child: Stack(children: [
      buildTabView(),
      StoragePanel(textEditingController: _textController)
    ]));
  }

  Widget buildTabView() {
    return ChangeNotifierProvider(
        create: (context) => BadgeNumProvider(),
        child: DefaultTabController(
            length: _kTabPages.length,
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
              drawer: NavDrawer(parentContext: _ctx),
              appBar: AppBar(
                title: Text('Keep'),
                backgroundColor: Colors.cyan,
                bottom: TabBar(
                  controller: _tabController,
                  tabs: <Tab>[
                    Tab(icon: const Icon(Icons.cloud), text: 'Fragmentation'),
                    Tab(icon: const Icon(Icons.alarm), text: 'Todo'),
                    Tab(
                        icon: Consumer<BadgeNumProvider>(
                          builder: (context, badge, child) => badge
                                      .badgeNumber >
                                  0
                              ? GestureDetector(
                                  onHorizontalDragCancel: () =>
                                      Provider.of<BadgeNumProvider>(context,
                                              listen: false)
                                          .clear(),
                                  onVerticalDragCancel: () =>
                                      Provider.of<BadgeNumProvider>(context,
                                              listen: false)
                                          .clear(),
                                  child: Badge(
                                      position: BadgePosition.bottomLeft(
                                          bottom: 12, left: 12),
                                      // padding: EdgeInsets.all(2.0),
                                      animationDuration:
                                          Duration(milliseconds: 300),
                                      animationType: BadgeAnimationType.fade,
                                      badgeColor:
                                          Colors.redAccent.withAlpha(225),
                                      badgeContent: Text(
                                          badge.badgeNumber > 99
                                              ? '99+'
                                              : badge.badgeNumber.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0)),
                                      child: child),
                                )
                              : child,
                          child: const Icon(Icons.forum),
                        ),
                        text: 'User'),
                  ],
                  labelColor: Color(0xFF343434),
                  labelStyle: textStyle.copyWith(
                      fontSize: 14.0,
                      color: Color(0xFFc9c9c9),
                      fontWeight: FontWeight.w700),
                  // unselectedLabelColor: Color(0xFFc9c9c9),
                  unselectedLabelColor: Colors.white,
                  unselectedLabelStyle: textStyle.copyWith(
                      fontSize: 14.0,
                      // color: Color(0xFFc9c9c9),
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
              body: ScrollConfiguration(
                  behavior: OverScrollBehavior(),
                  child: TabBarView(
                    controller: _tabController,
                    children: _kTabPages,
                  )),
            )));
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         SecondScreen(receivedNotification.payload),
                //   ),
                // );
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen(tapAction);
  }

  tapAction(String payload) {
    if (payload != null && payload.length > 0) {
      debugPrint("payload : $payload");
      List<String> payData = payload.split('-');
      int typeId = int.parse(payData[0]);
      int targetId = int.parse(payData[1]);
      // selectNotificationSubject.add('0-0');
      handleTapNavAction(typeId, targetId);
    }
  }

  void handleTapNavAction(int typeId, int targetId) async {
    // debugPrint('enter ===============>');
    switch (typeId) {
      case 0:
        debugPrint('do not have any notification.');
        break;
      case 1:
        debugPrint('enter to nav to user chat screen===============>');
        Friend friend = FriendProvider.getFriendById(targetId);
        msgRepo.getMessagesByRecvId(1, targetId).then((messages) {
          Navigator.of(_ctx).push(new MaterialPageRoute(builder: (_) {
            debugPrint('navigation==========================>');
            return ChatScreen(
                userType: 1,
                // username: username,
                // avatar: avatar,
                friend: friend,
                messages: messages);
          }));
        });
        break;
      case 2:
        Friend friend = FriendProvider.getFriendById(targetId);
        // _cancelNotification(targetId);
        Navigator.of(_ctx).push(new MaterialPageRoute(builder: (_) {
          return ChatScreen(
              userType: 1,
              // username: username,
              // avatar: avatar,
              friend: friend,
              messages: []);
        }));
        break;
      case 3:
        break;
    }
  }
}
