import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:keep/global/search_header.dart';
import 'package:keep/models/recent_model.dart';
import 'package:keep/data/provider/user_provider.dart';
// import 'package:keep/models/recent_contacts.dart';
import 'package:keep/widget/user_pic.dart';
import 'package:keep/data/repository/recent_contacts_repository.dart';

class RecentContactsList extends StatefulWidget {
  final double topPadding;
  RecentContactsList({this.topPadding, Key key}) : super(key: key);

  @override
  _RecentContactsListState createState() => _RecentContactsListState();
}

class _RecentContactsListState extends State<RecentContactsList> {
  final int userId = UserProvider.getUserId();
  final rcRepo = new RecentContactRepository();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: buildRecentContacts()
    );
  }

  Widget buildRecentContacts() {
    return FutureBuilder<List<RecentModel>>(
      future: rcRepo.getRecentContacts(userId),
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
