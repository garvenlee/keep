import 'package:flutter/material.dart';
import 'package:keep/utils/sputil.dart';
import 'package:keep/UI/Home/chat/chat_mainpage.dart';
import 'nav_drawer.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _kTabPages = <Widget>[
    Center(child: Icon(Icons.cloud, size: 64.0, color: Colors.teal)),
    Center(child: Icon(Icons.alarm, size: 64.0, color: Colors.cyan)),
    HomeView(),
  ];
  final _kTabs = <Tab>[
    Tab(icon: Icon(Icons.cloud), text: 'Fragmentation'),
    Tab(icon: Icon(Icons.alarm), text: 'Todo'),
    Tab(icon: Icon(Icons.forum), text: 'User'),
  ];
  String _username;
  String _email;
  // String _apiKey;
  String _userPic;

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
    // print(_userPic);
    return Container(
        child: DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Keep'),
          backgroundColor: Colors.cyan,
          bottom: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    ));
  }
}
