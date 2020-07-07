import 'package:provider/provider.dart';
import 'package:after_layout/after_layout.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';

import 'package:keep/service/socket_util.dart';
import 'package:keep/BLoC/message_bloc.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/utils/event_util.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/models/group.dart';
import 'package:keep/models/group_client.dart';
import 'package:keep/settings/selection_config.dart';

import 'chat_item.dart';

// 传参应该是friend/group + _friends
class ChatScreen extends StatefulWidget {
  final int userType; // 1 is p2p, 2 is chatroom
  // final String username;
  // final Object avatar;
  final Friend friend;
  final Group group;
  final Map<int, GroupClient> members;
  final List<UserMessage> messages;
  ChatScreen(
      {this.userType,
      // this.username,
      // this.avatar,
      this.friend,
      this.group,
      this.members,
      this.messages,
      int getData});

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin, AfterLayoutMixin<ChatScreen> {
  // additinal controller
  bool _isobscure = false;
  // bool _isComposing = false;
  final ScrollController scrollController = new ScrollController();
  final TextEditingController textEditingController =
      new TextEditingController();
  final msgBloc = new MessageBloc();

  // my info
  final String apiKey = UserProvider.getApiKey();
  final int userId = UserProvider.getUserId();
  final Object avatar = UserProvider().userAvatar;
  final String username = UserProvider().username;

  // global info - context and netStatus
  BuildContext _ctx;
  SocketIO _socket;
  String dropdownValue = 'One';

  // other info
  int toUserId;

  // hold the last chat time in sec
  int lastTimestampSec = 0;

  // message info
  List<UserMessage> _messages = <UserMessage>[];
  List<ChatItemWidget> _messageItems = <ChatItemWidget>[];
  List<UserMessage> _offlineMsg = <UserMessage>[];
  List<int> offlineDeleteId = [];
  List<int> onlineDelateId = [];
  int offlineMsgLength = 0;
  int chatItemLength = 0;
  int offlineNumCal = 0;
  // bool updateFlag = false;

  initSocket() async {
    return await new SocketUtil().socket;
  }

  void _unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(_ctx);
    if (!currentFocus.hasPrimaryFocus) {
      print('unfocus');
      currentFocus.unfocus();
    }
  }

  void newMessage({UserMessage msg, String creatorName}) {
    int timestampSec = (msg.createAt / 1000).floor();
    // whether display the timestamp
    bool timestampFlag = (timestampSec - lastTimestampSec) > 600;
    ChatItemWidget chatMessage = new ChatItemWidget(
        id: chatItemLength,
        username: creatorName,
        avatar: msg.creatorId == toUserId
            ? widget.userType == 1
                ? widget.friend.avatar
                : widget.members[toUserId].userAvatarObj
            : avatar,
        text: msg.messageBody,
        animationController: new AnimationController(
            duration: new Duration(milliseconds: 700), //new
            vsync: this),
        isSelf: msg.creatorId == userId,
        timestampFlag: timestampFlag,
        timestamp: msg.createAt,
        success: true); // forward the message at the chatscreen
    //used to rebuild our widget
    setState(() {
      _messageItems.add(chatMessage);
      lastTimestampSec = timestampSec;
      chatItemLength = chatItemLength + 1;
      // updateFlag = true;
      chatMessage.animationController.forward();
    });
  }

  @override
  void initState() {
    super.initState();
    print('chat type is ${widget.userType}');
    toUserId =
        widget.userType == 1 ? widget.friend.userId : widget.group.roomId;
    print('群组ID： $toUserId');
    print(userId);
    print('群组成员个数： ${widget.members}');
    // print("chatscreen toUserId is $toUserId");
    _messages = widget.messages;
    if (_messages.length > 0)
      lastTimestampSec =
          (_messages[_messages.length - 1].createAt / 1000).floor();
    else
      lastTimestampSec = 0;

    // print('from message to chatItem.................');
    widget.userType == 1 ? setUserChatItems() : setGroupChatItems();
  }

  void chatCallback(stream) {
    print(stream['chat_type']);
    print(widget.userType);
    if (stream['chat_type'] == widget.userType &&
        (stream['recipient_id'] == userId ||
            stream['recipient_id'] == toUserId)) {
      UserMessage msg = UserMessage.fromMap(stream);
      newMessage(msg: msg, creatorName: stream["creator_name"]);
      msgBloc.addMessage(msg);
    } else {
      print('use homepage socket on');
      // stream['context'] = context;
      onChatCallback(stream);
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    initSocket().then((socket) {
      _socket = socket;
      _socket.on('chat', chatCallback);
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    for (ChatItemWidget message in _messageItems)
      message.animationController?.dispose();
    _socket.off('chat', chatCallback);
    bus.on('delete_chat_item', (id) => deleteMessage(id));
    msgBloc.dispose();
    super.dispose();
  }

  void _submit(connectionStatus) {
    //Check if the textfield has text or not
    if (textEditingController.text.isNotEmpty) {
      // msg send success or fail
      bool success = false;
      // msg send time/ms
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      int timestampSec = (timestamp / 1000).floor();
      // whether display the timestamp
      bool timestampFlag = (timestampSec - lastTimestampSec) > 600;

      UserMessage msg = new UserMessage(
        chatType: widget.userType,
        messageType: 'text',
        messageBody: textEditingController.text,
        creatorId: userId,
        recipientId: toUserId,
        recipientGroupId: toUserId,
        createAt: timestamp,
        expiredAt: timestamp + 30 * 24 * 60 * 60 * 1000,
      );

      if (connectionStatus == ConnectivityStatus.Available) {
        //Send the message as JSON data to send_message event
        sendMessage(timestamp);
        success = true;
        // save message
        // print('add msg in UserMessage Table');
        msgBloc.addMessage(msg);
        // MessageProvider().newMessage(msg);
      } else {
        // if offline, save the message waiting to send again
        // print('save offline message......');
        msg.isOnline = 0;
        msgBloc.addMessage(msg);
        setState(() => offlineNumCal += 1);
        // MessageProvider.saveMessage(msg);
      }
      // print('insert into _messageslist');
      // print(chatItemLength);
      // message item
      ChatItemWidget chatMessage = new ChatItemWidget(
          id: chatItemLength,
          username: username,
          avatar: msg.creatorId == toUserId
              ? widget.userType == 1
                  ? widget.friend.avatar
                  : widget.members[toUserId].userAvatarObj
              : avatar,
          text: textEditingController.text,
          animationController: new AnimationController(
              duration: new Duration(milliseconds: 700), //new
              vsync: this),
          isSelf: true,
          timestampFlag: timestampFlag,
          timestamp: timestamp,
          success: success); // forward the message at the chatscreen
      setState(() {
        //used to rebuild our widget
        _messageItems.add(chatMessage);
        lastTimestampSec = timestampSec;
        chatItemLength = chatItemLength + 1;
        // updateFlag = true;
      });
      chatMessage.animationController.forward();
      textEditingController.clear();
    }
  }

  void sendMessage(int timestamp) {
    // print('send msg..................');
    String chatType = widget.userType == 1 ? 'chat' : 'GroupChat';
    _socket.emit(chatType, [
      {
        'chat_type': widget.userType,
        'message_type': 'text',
        'message_body': textEditingController.text,
        'creator_name': username,
        'creator_id': this.userId,
        'recipient_id': toUserId,
        'create_at': timestamp,
        'is_offline': 0
      }
    ]);
    print('send done.......................');
  }

  void deleteMessage(int id) {
    setState(() {
      print('delete item....................');
      // updateFlag = true;
      if (id < this.offlineMsgLength) {
        int indicatorId = 0;
        for (final int val in offlineDeleteId) {
          if (id > val) {
            indicatorId += 1;
          } else
            break;
        }
        offlineDeleteId.add(id);
        // 考虑前面删除项的影响，更正索引
        int realId = id - indicatorId;
        _messageItems.removeAt(realId);
        // MessageProvider.delete(_offlineMsg[realId].createAt);
        _offlineMsg.removeAt(id - indicatorId);
      } else {
        int indicatorId = offlineDeleteId.length;
        for (final int val in onlineDelateId) {
          if (id > val) {
            indicatorId += 1;
          } else
            break;
        }
        onlineDelateId.add(id);
        // 在_messageItems前面本来是
        int realId1 = id - indicatorId;
        int realId2 = realId1 - offlineMsgLength + offlineDeleteId.length;
        // int realId2 = id - offlineMsgLength - (indicatorId - offlineDeleteId.length);
        _messageItems.removeAt(realId1);
        msgBloc.deleteMessage(
            _messages[realId2].createAt, _messages[realId2].creatorId);
        _messages.removeAt(realId2);
      }
      chatItemLength = chatItemLength - 1;
    });
  }

  void setUserChatItems() {
    // print('set user messages==============>');
    // print(allMsgs.length);
    List<ChatItemWidget> messageItems = <ChatItemWidget>[];
    int lastTimestamp = _messages.length > 0 ? _messages[0].createAt : 0;
    // bool flag;
    _messages.asMap().forEach((index, msg) {
      if (msg.isRead == 0) {
        // print('need to update isRead field');
        msgBloc.updateMessage(msg: msg);
        // updateFlag = true;
      }
      messageItems.add(new ChatItemWidget(
          id: index,
          username:
              msg.creatorId == toUserId ? widget.friend.username : username,
          avatar: msg.creatorId == toUserId ? widget.friend.avatar : avatar,
          text: msg.messageBody,
          isSelf: msg.creatorId == this.userId,
          timestampFlag:
              ((msg.createAt - lastTimestamp) > 600000) || index == 0,
          timestamp: msg.createAt,
          success: msg.isOnline == 1));
      lastTimestamp = msg.createAt;
    });
    _messageItems = messageItems;
    chatItemLength = _messageItems.length;
    // print(chatItemLength);
  }

  void setGroupChatItems() {
    List<ChatItemWidget> messageItems = <ChatItemWidget>[];
    int lastTimestamp = _messages.length > 0 ? _messages[0].createAt : 0;
    _messages.asMap().forEach((index, msg) {
      if (msg.isRead == 0) {
        msgBloc.updateMessage(msg: msg);
        // updateFlag = true;
      }
      messageItems.add(new ChatItemWidget(
          id: index,
          username: msg.creatorId == toUserId
              ? widget.members[toUserId].username
              : username,
          avatar: msg.creatorId == toUserId
              ? widget.members[toUserId].userAvatarObj
              : avatar,
          text: msg.messageBody,
          isSelf: msg.creatorId == this.userId,
          timestampFlag:
              ((msg.createAt - lastTimestamp) > 600000) || index == 0,
          timestamp: msg.createAt,
          success: msg.isOnline == 1));
    });
    _messageItems = messageItems;
    chatItemLength = _messageItems.length;
    // print(chatItemLength);
  }

  Future<bool> _onPop(BuildContext context) {
    // Navigator.pop(context, updateFlag);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    bus.on('delete_chat_item', (id) => deleteMessage(id));
    return WillPopScope(
        onWillPop: () => _onPop(context),
        child: GestureDetector(
            onTap: () => _unfocus(),
            child: new Scaffold(
                // leads input bar not padding
                // resizeToAvoidBottomPadding: false,
                body: SafeArea(
                    child: new Column(
              children: <Widget>[
                buildHeader(),
                new Expanded(
                  child: new ListView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: new EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) {
                      int idx = _messageItems.length - 1 - index;
                      // print(idx);
                      var msgItem = _messageItems[idx];
                      // msgItem.animationController.forward();
                      return msgItem;
                    },
                    itemCount: _messageItems.length,
                  ),
                ),
                new Divider(
                  height: 1.0,
                ),
                new Container(
                    height: 54,
                    decoration: new BoxDecoration(
                      color: Theme.of(context).cardColor,
                    ),
                    child: _textComposerWidget())
              ],
            )))));
  }

  Widget buildStatusBar() {
    return _isobscure ? Text(' is typing a message...') : Container();
  }

  Widget buildChatInput() {
    return new Flexible(
        child: new Container(
            // width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(2.0),
            child: Container(
              height: 40.0,
              child: TextField(
                  maxLines: 10,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    hintText: "Send a message",
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                  ),
                  controller: textEditingController),
            )));
  }

  Widget buildFaceTool() {
    return Material(
      child: new Container(
        width: 36.0,
        // margin: new EdgeInsets.symmetric(horizontal: 1.0),
        child: new IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => {},
          icon: new Icon(Icons.face),
          color: Colors.grey,
        ),
      ),
      color: Colors.white,
    );
  }

  Widget buildLink() {
    return Material(
      child: new Container(
        // margin: new EdgeInsets.symmetric(horizontal: 1.0),
        width: 36.0,
        child: new IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => {},
          icon: new Icon(Icons.link),
          color: Colors.grey,
        ),
      ),
      color: Colors.white,
    );
  }

  Widget buildSendButton() {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, _) {
      return new Container(
          // margin: const EdgeInsets.symmetric(horizontal: 20.0),
          height: 45.0,
          child: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            onPressed: () => _submit(connectionStatus),
            child: Icon(
              Icons.send,
              size: 25,
            ),
          ));
    });
  }

  Widget _textComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        // height: 50.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            buildFaceTool(),
            buildLink(),
            buildChatInput(),
            buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        padding: new EdgeInsets.only(right: 8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 3,
                  child: Container(
                      width: MediaQuery.of(_ctx).size.width * 0.15,
                      child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            // Navigator.pop(_ctx, updateFlag);
                            Navigator.pop(_ctx);
                          }))),
              Flexible(
                  flex: 10,
                  child: Container(
                      width: MediaQuery.of(_ctx).size.width * 0.5,
                      child: Text(
                          capitalize(widget.userType == 1
                              ? widget.friend.username
                              : widget.group.roomName),
                          style: TextStyle(
                              // color: Colors.white70,
                              fontSize: 16.0)))),
              Flexible(
                  flex: 12,
                  child: Container(
                      // width: MediaQuery.of(_ctx).size.width * 0.3,
                      child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                      // value: dropdownValue,
                      iconEnabledColor: Color(0xFF595959),
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                      ),
                      iconSize: 24,
                      elevation: 8,
                      isExpanded: true,
                      isDense: true,
                      // style: TextStyle(color: Colors.deepPurple),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>[
                        'Search',
                        'Mute Notifications',
                        'Chat history',
                        'Clear history'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                            onTap: () {},
                            value: value,
                            child: Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: chatSelections[value]),
                                Text(
                                  value,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ));
                      }).toList(),
                    )),
                  )))
            ]));
  }
}
