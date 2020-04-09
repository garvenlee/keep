import 'package:flutter/material.dart';
import 'package:keep/models/get_user.dart';
import '../friends/friends_list.dart';
import 'search_region.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class EditSelectPage extends StatefulWidget {
  EditSelectPage({Key key}) : super(key: key);

  @override
  _EditSelectPageState createState() => _EditSelectPageState();
}

class _EditSelectPageState extends State<EditSelectPage> {
  var _searchController = new TextEditingController();
  var _focusNode = new FocusNode();

  Widget _buildListView(BuildContext context, AsyncSnapshot snapshot) {
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
        return Container(
            child: new ListView(
          children: <Widget>[
            buildSearchHeader(context, _searchController, _focusNode),
            new Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Add Contact'),
                    onTap: () => {},
                  ),
                  ListTile(
                    leading: Icon(Icons.group_add),
                    title: Text('Add ChatRoom'),
                    onTap: () => {},
                  ),
                ],
              ),
            ),
            new Container(
                padding: EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
                color: Colors.grey.withAlpha(30),
                child: Text('Sorted by last seen time')),
            FriendsList(snapshot.data),
          ],
        ));
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.blueAccent.withOpacity(0.7),
          onPressed: () => {
            // Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            //   return SearchRegion();
            // }))
          },
          tooltip: 'Add contact',
          child: new Icon(Icons.add),
        ),
        body: FutureBuilder(
          builder: _buildListView,
          future: getEmail(),
        ));
  }
}
