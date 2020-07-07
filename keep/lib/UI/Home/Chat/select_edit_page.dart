import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:keep/UI/Home/Chat/AddContact/add_contacts.dart';
import 'package:keep/UI/Home/Chat/AddRoom/add_room.dart';
import 'package:keep/widget/search_header.dart';
import 'package:keep/widget/user_pic.dart';
import 'package:keep/models/recent_model.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/repository/recent_contacts_repository.dart';

import 'Contacts/recent_contacts_list.dart';

class EditSelectPage extends StatefulWidget {
  EditSelectPage({Key key}) : super(key: key);

  @override
  _EditSelectPageState createState() => _EditSelectPageState();
}

class _EditSelectPageState extends State<EditSelectPage> {
  var _searchController = new TextEditingController();
  var _focusNodeHeader = new FocusNode();
  final int userId = UserProvider.getUserId();
  final rcRepo = new RecentContactRepository();
  Future<List<RecentModel>> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = rcRepo.getRecentContacts(userId);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Container(
            child: new ListView(
      children: <Widget>[
        buildSearchHeader(context, _searchController, _focusNodeHeader),
        new Container(
          child: Column(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.person_add),
                  title: Text('Add Contact'),
                  onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) => AddContactsPage(context: context)))),
              ListTile(
                  leading: Icon(Icons.group_add),
                  title: Text('Add ChatRoom'),
                  onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                      builder: (_) => AddRoomPage(context: context))))
            ],
          ),
        ),
        new Container(
            padding: EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
            color: Colors.grey.withAlpha(30),
            child: Text('Sorted by last seen time')),
        // FriendsList(topPadding: 250),
        // buildRContactsList(topPadding: 250)
        RecentContactsList(topPadding: 250)
      ],
    )));
  }

  Widget buildRContactsList({double topPadding}) {
    return FutureBuilder<List<RecentModel>>(
      future: _contacts,
      builder:
          (BuildContext context, AsyncSnapshot<List<RecentModel>> snapshot) {
        Widget page;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            // return Text('awaiting begin sink data......');
            page = Container();
            break;
          case ConnectionState.waiting:
            print('awaiting result.......');
            // return Text('awaiting result......');
            page = Container();
            break;
          default:
            List<RecentModel> rdata = <RecentModel>[];
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              // return Text(snapshot.error.toString());
              page = Container();
            } else if (snapshot.hasData) {
              // print(snapshot.data);
              rdata = snapshot.data;
              page = buildContactList(rdata);
            }
        }
        return page;
      },
    );
  }

  Widget buildContactList(List<RecentModel> rdata) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: rdata.length,
      itemBuilder: (BuildContext context, int index) {
        return buildContactItem(index, rdata[index]);
      },
    );
  }

  Widget buildContactItem(int index, RecentModel data) {
    Object avatar = data.avatar;
    return ListTile(
      leading: new Hero(
          tag: index,
          child: avatar != 'null'
              ? CircleAvatar(backgroundImage: avatar)
              : normalUserPic(
                  username: data.name,
                  picRadius: 25.0,
                  fontSize: 20.0,
                  fontColor: Colors.white,
                  bgColor: Colors.indigoAccent)),
      title: Text(data.name),
      subtitle: Text(data.account),
      trailing: Text(DateFormat('dd MMM kk:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(data.lastSeenTime))),
    );
  }
}
