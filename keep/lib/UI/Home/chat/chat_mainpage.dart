import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'XKTabBar.dart';
import './chatscreen.dart';
// import './new_contact.dart';
// import './home/searchPage.dart';
import './edit_select_page.dart';
// import './user/talk.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => new _HomeViewState();
}

class _HomeViewState extends State {
  final SlidableController slidableController = new SlidableController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildListView(),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.blueAccent.withOpacity(0.7),
        onPressed: () => 
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return EditSelectPage();
          }))
        ,
        tooltip: 'Add contact',
        child: new Icon(Icons.edit),
      ),
    );
  }

  _showSnackBar(val) {
    print(val);
  }

  returnUserItem() {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(new MaterialPageRoute(builder: (context) {
                return new ChatScreen();
              }));
            },
            leading: CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.indigoAccent,
              child: Text('g'),
              foregroundColor: Colors.white,
            ),
            title: Text('garvenlee'),
            subtitle: Text('SlidableDrawerDelegate'),
            trailing: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text("6:00"),
                      new CircleAvatar(
                        radius: 10,
                          backgroundColor: const Color(0xFFf46464),
                          child: Text('22+', style: TextStyle(fontSize: 10.0),),
                          foregroundColor: Colors.white,
                        ),
                    ]))),
      ),
      // actions：前置slidabel
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Sticky',
          color: Color(0xFF61ab32),
          icon: Icons.vertical_align_top,
          onTap: () => _showSnackBar('More'),
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => _showSnackBar('Delete'),
        ),
      ],
    );
  }

  ListView _buildListView() {
    return new ListView(
      children: <Widget>[
        returnUserItem(),
      ],
    );
  }
}
