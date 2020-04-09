import 'package:flutter/material.dart';
import './nav_drawer.dart';
import '../../models/get_user.dart';
import '../Home/chat/chat_mainpage.dart';

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

  Future<void> _loadUser() async {
    Future<String> username = getUsername();
    Future<String> email = getEmail();
    // Future<String> apiKey = getApiKey();
    Future<String> userPic = getUserPic();

    username.then((val) => setState(() => _username = val));
    email.then((val) => setState(() => _email = val));
    // apiKey.then((val) => setState(() => _apiKey = val));
    userPic.then((val) => setState(() => _userPic = val));
  }

  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        drawer: NavDrawer(_username, _email, _userPic),
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
