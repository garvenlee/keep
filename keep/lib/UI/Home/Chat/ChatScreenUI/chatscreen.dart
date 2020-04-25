import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:keep/BLoC/message_bloc.dart';
import 'package:keep/data/provider/message_provider.dart';
import 'package:keep/utils/event_util.dart';
import 'package:keep/utils/socket_util.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/global/connectivity_status.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/models/message.dart';
import 'package:provider/provider.dart';
import 'message_item.dart';

class ChatScreen extends StatefulWidget {
  final int userType; // 1 is p2p, 2 is chatroom
  final String username;
  final String toUsername; // required when p2p
  final int toUserId;
  final String toRoomname; // required when group
  final List<Message> onlineMessage;
  final List<Message> offlineMessage;
  ChatScreen(
      {this.userType,
      this.username,
      this.toUsername,
      this.toUserId,
      this.toRoomname,
      this.onlineMessage,
      this.offlineMessage});

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  // additinal controller
  bool _isobscure = false;
  // bool _isComposing = false;
  final ScrollController scrollController  = new ScrollController();
  final TextEditingController textEditingController = new TextEditingController();
  final MessageBloc bloc = MessageBloc();

  // my info
  final String apiKey = UserProvider.getApiKey();
  final int userId = UserProvider.getUserId();

  // global info - context and netStatus
  BuildContext _ctx;
  var connectionStatus;
  SocketIO _socket;
  String dropdownValue = 'One';

  // other info
  int toUserId;

  // hold the last chat time in sec
  int lastTimestampSec = 0;

  // message info
  List<Message> _messages = <Message>[];
  List<ChatItemWidget> _messageItems = <ChatItemWidget>[];
  List<Message> _offlineMsg = <Message>[];
  List<int> offlineDeleteId = [];
  List<int> onlineDelateId = [];
  int offlineMsgLength = 0;

  initSocket() async {
    return await new SocketUtil().socket;
  }

  @override
  void initState() {
    super.initState();
    initSocket().then((socket) => _socket = socket);

    toUserId = widget.toUserId;

    // print('from message to chatItem.................');
    setChatItems();

    bus.on('delete_chat_item', (id) => deleteMessage(id));
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    for (ChatItemWidget message in _messageItems)
      message.animationController.dispose();
    super.dispose();
  }


  void _submit() {
    //Check if the textfield has text or not
    if (textEditingController.text.isNotEmpty) {
      // msg send success or fail
      bool success = false;
      // msg send time/ms
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      int timestampSec = (timestamp / 1000).floor();
      // whether display the timestamp
      bool timestampFlag = (timestampSec - lastTimestampSec) > 120;

      Message msg = new Message(
        chatType: 1,
        messageType: 'text',
        messageBody: textEditingController.text,
        creatorId: userId,
        recipientId: toUserId,
        createAt: timestamp,
        expiredAt: timestamp + 30 * 24 * 60 * 60 * 1000,
      );

      if (connectionStatus == ConnectivityStatus.Available) {
        //Send the message as JSON data to send_message event
        sendMessage(timestamp);
        success = true;
        // save message
        print('add msg in Message Table');
        bloc.addMessage(msg);
      } else {
        // if offline, save the message waiting to send again
        print('save offline message......');
        MessageProvider.saveMessage(msg);
      }
      print('insert into _messageslist');

      // message item
      ChatItemWidget chatMessage = new ChatItemWidget(
          username: widget.username,
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
        _messageItems.insert(0, chatMessage);
        lastTimestampSec = timestampSec;
      });
      chatMessage.animationController.forward();
      textEditingController.clear();
    }
  }

  void sendMessage(int timestamp) {
    print('send msg..................');
    _socket.emit("chat", [
      {
        'chat_type': 1,
        'message_type': 'text',
        'message_body': textEditingController.text,
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
        MessageProvider.delete(_offlineMsg[realId].createAt);
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
        bloc.deleteMessage(
            _messages[realId2].createAt, _messages[realId2].creatorId);
        _messages.removeAt(realId2);
      }
    });
  }

  void setChatItems() {
    _messages = widget.onlineMessage;
    if (_messages.length > 0) {
      _messages.sort((left, right) => (left.createAt > right.createAt ? 0 : 1));
    }
    List<Message> allMsgs;
    if (widget.offlineMessage.length == 0) {
      allMsgs = MessageProvider.getMessageByReId(toUserId);
    } else {
      allMsgs = widget.offlineMessage;
    }
    _offlineMsg = allMsgs;
    offlineMsgLength = allMsgs.length;
    allMsgs.addAll(_messages);
    List<ChatItemWidget> messageItems = <ChatItemWidget>[];
    allMsgs.asMap().forEach((index, msg) {
      messageItems.add(new ChatItemWidget(
          id: index,
          username:
              msg.creatorId == toUserId ? widget.toUsername : widget.username,
          text: msg.messageBody,
          animationController: new AnimationController(
              duration: new Duration(milliseconds: 700), //new
              vsync: this),
          isSelf: msg.creatorId == this.userId,
          timestampFlag: false,
          timestamp: msg.createAt,
          success: msg.isRead == 1));
    });
    _messageItems = messageItems;
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    return new Scaffold(
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
              var msgItem = _messageItems[index];
              msgItem.animationController.forward();
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
          child: _textComposerWidget(),
        )
      ],
    )));
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
                controller: textEditingController,
                // onChanged: (String text) {
                //   setState(() {
                //     _isComposing = text.length > 0;
                //   });
                // },
                // onSubmitted: _handleSubmitted,
              ),
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
    return new Container(
        // margin: const EdgeInsets.symmetric(horizontal: 20.0),
        height: 45.0,
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: _submit,
          child: Icon(
            Icons.send,
            size: 25,
          ),
        ));
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
                            Navigator.of(_ctx).pop();
                          }))),
              Flexible(
                  flex: 10,
                  child: Container(
                      width: MediaQuery.of(_ctx).size.width * 0.5,
                      child: Text(capitalize(widget.toUsername),
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
