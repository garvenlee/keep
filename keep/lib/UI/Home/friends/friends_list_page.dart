import 'package:flutter/material.dart';
import 'package:keep/models/get_user.dart';
import '../chat/search_region.dart';
import './friends_list.dart';

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
        body: FutureBuilder(
      builder: _buildFriendsList,
      future: getEmail(),
    ));
  }

  Widget _buildFriendsList(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
        print('email has not been gotten!');
        return Container();
      case ConnectionState.active:
        print('active');
        return Container();
      case ConnectionState.waiting:
        print('waiting');
        return Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.done:
        print('done');
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        return new Container(
            child: ListView(
          children: <Widget>[
            buildSearchHeader(context, _searchController, _focusNode),
            FriendsList(snapshot.data),
          ],
        ));
      default:
        return null;
    }
  }
}
