import 'package:flutter/material.dart';
import 'package:keep/utils/sputil.dart';
import 'package:keep/utils/user_pic.dart';
import 'package:keep/global/global_tool.dart';
import 'friends/friends_list_page.dart';
import 'Settings/setting_main_page.dart';

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String _username;
  String _email;
  String _userPic;
  Widget buildUserPic() {
    if (_userPic == 'null') {
      return Container(
          // decoration:
          //     BoxDecoration(border: Border.all(color: Colors.red)),
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: normalUserPic(
              username: _username,
              picRadius: 30.0,
              fontSize: 20.0,
              fontColor: Colors.white,
              bgColor: Colors.indigoAccent));
    } else {
      var avatar = txt2Image(_userPic);
      return Container(
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            border: new Border.all(
                color: Colors.white.withAlpha(100), width: 1), // 边色与边宽度
            color: Color(0xFF9E9E9E), // 底色
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: CircleAvatar(radius: 30.0, backgroundImage: avatar));
    }
  }

  void _loadUser() {
    setState(() {
      _username = SpUtil.getString('username');
      _email = SpUtil.getString('email');
      _userPic = SpUtil.getString('userPic');
    });
  }

  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BuildContext _ctx = context;
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
                  buildUserPic(),
                  Container(
                      // decoration:
                      //     BoxDecoration(border: Border.all(color: Colors.red)),
                      // padding: EdgeInsets.only(right: 35.0, top: 25.0),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(capitalize(_username),
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600))),
                      Container(
                          child: Text(_email,
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
            onTap: () => Navigator.of(context).pop(),
          ),
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
            onTap: () async {
              await Navigator.of(context)
                  .push<UpgradeUserPic>(new MaterialPageRoute(builder: (_) {
                return SettingMainPage(_username, _email, _userPic);
              })).then((res) {
                if (res != null) {
                  setState(() {
                    print(res.stream['avatar']);
                    if (res.stream['avatar'] != 'null') {
                      _userPic = res.stream['avatar'];
                    }
                  });
                }
              });
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
                              print("you choose no");
                              Navigator.of(context).pop(false);
                            },
                            child: Text('Cancel'),
                          ),
                          FlatButton(
                            onPressed: () async {
                              SpUtil.clear();
                              Navigator.of(_ctx).pushNamedAndRemoveUntil(
                                  "/login", (Route<dynamic> route) => false);
                              // SystemChannels.platform
                              //     .invokeMethod('SystemNavigator.pop');
                            },
                            child: Text('Log Out'),
                          ),
                        ],
                      ))))
        ]));
  }
}
