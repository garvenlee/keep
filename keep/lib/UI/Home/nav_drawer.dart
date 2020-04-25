import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:keep/UI/storageBox/storage_box.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/global/user_pic.dart';
import 'package:provider/provider.dart';
import 'friends/friends_list_page.dart';
import 'Settings/setting_main_page.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Drawer(
          child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/nav_me.jpg"),
                        fit: BoxFit.cover)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    UserAvatar(user.username, user.avatar),
                    Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(capitalize(user.username),
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600))),
                        Container(
                            child: Text(user.email,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400)))
                      ],
                    )),
                  ],
                )),
            ListTile(
              leading: Icon(Icons.group_add),
              title: Text('New Group'),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.notifications_active),
              title: Text('Notifications'),
              trailing: CircleAvatar(
                radius: 10.0,
                child: new Text('3',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                backgroundColor: const Color(0xFFf46464),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
                leading: Icon(Icons.collections_bookmark),
                title: Text('Storage Box'),
                // trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
                onTap: () => Navigator.of(context)
                        .push(new MaterialPageRoute(builder: (_) {
                      return StorageBox(title: 'demo');
                    }))),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Contacts'),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return FriendsListPage();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('ChatRooms'),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Send Feedback'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('settings'),
              // trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
              onTap: () {
                Navigator.of(context)
                    .push(new MaterialPageRoute(builder: (_) {
                  return SettingMainPage();
                }));
              },
            ),
            Divider(
              height: 1.0,
            ),
            ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Log out'),
                onTap: () => showDialog(
                    context: context,
                    child: FractionallySizedBox(
                        widthFactor: 0.85,
                        child: AlertDialog(
                          elevation: 5.0,
                          // actionsPadding: EdgeInsets.symmetric(horizontal: 80.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          title: Center(child: Text('Are You Sure?')),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Center(child: Text('You are about to leave.')),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () {
                                // print("you choose no");
                                Navigator.of(context).pop(false);
                              },
                              child: Text('Cancel'),
                            ),
                            FlatButton(
                              onPressed: logout(context),
                              child: Text('Log Out'),
                            ),
                          ],
                        ))))
          ]));
    });
  }
}
