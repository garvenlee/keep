import 'package:flutter/material.dart';
import 'package:keep/widget/search_header.dart';
import 'room_list.dart';

class ChatRoomPage extends StatefulWidget {
  ChatRoomPage({Key key}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  var _searchController = new TextEditingController();
  var _focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: ListView(
              shrinkWrap: true,
      children: <Widget>[
        buildSearchHeader(context, _searchController, _focusNode),
        RoomsList(topPadding: 80.0,)
      ],
    )));
  }
}
