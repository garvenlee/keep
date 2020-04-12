import 'package:flutter/material.dart';
import 'package:keep/utils/search_header.dart';
import 'package:keep/utils/sputil.dart';
import 'friends_list.dart';


class FriendsListPage extends StatefulWidget {
  FriendsListPage({Key key}) : super(key: key);

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  var _searchController = new TextEditingController();
  var _focusNode = new FocusNode();
  String _email;

  @override
  void initState() {
    setState(() {
      _email = SpUtil.getString('email');
    });
    print(_email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: ListView(
      children: <Widget>[
        buildSearchHeader(context, _searchController, _focusNode),
        FriendsList(),
      ],
    )));
  }
}
