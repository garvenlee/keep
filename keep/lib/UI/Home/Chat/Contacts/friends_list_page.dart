import 'package:flutter/material.dart';
import 'package:keep/widget/search_header.dart';
import 'friends_list.dart';


class FriendsListPage extends StatefulWidget {
  FriendsListPage({Key key}) : super(key: key);

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  var _searchController = new TextEditingController();
  var _focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: ListView(
      children: <Widget>[
        buildSearchHeader(context, _searchController, _focusNode),
        FriendsList(topPadding: 80.0),
      ],
    )));
  }
}
