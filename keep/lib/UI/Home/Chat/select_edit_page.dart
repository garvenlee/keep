import 'package:flutter/material.dart';
import 'package:keep/UI/Home/friends/friends_list.dart';
import 'package:keep/global/search_header.dart';
import 'package:keep/UI/Home/Chat/AddContact/add_contacts.dart';

class EditSelectPage extends StatefulWidget {
  EditSelectPage({Key key}) : super(key: key);

  @override
  _EditSelectPageState createState() => _EditSelectPageState();
}

class _EditSelectPageState extends State<EditSelectPage> {
  var _searchController = new TextEditingController();
  var _focusNode = new FocusNode();

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
        body: Container(
            child: new ListView(
          children: <Widget>[
            buildSearchHeader(context, _searchController, _focusNode),
            new Container(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Add Contact'),
                    onTap: () => Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (_) => AddContactsPage())),
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
            FriendsList(),
          ],
        )));
  }
}
