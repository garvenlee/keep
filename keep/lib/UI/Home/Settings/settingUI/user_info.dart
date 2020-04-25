import 'package:flutter/material.dart';

class UserInfo extends StatefulWidget {
  final String username;
  final String email;
  final String bio;
  UserInfo({this.username, this.email, this.bio, Key key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String _username;
  String _bio;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _bio = widget.bio;
  }

  void changeUsername(String username) {
    setState(() {
      _username = username;
    });
  }

  void changeBio(String bio) {
    setState(() {
      _bio = bio;
    });
  }

  Widget buildBottom() {
    return Container(
        height: 0.5,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)))));
  }

  Widget buildItem(Icon icon, String heading, String tail, Function callback) {
    return Container(
        child: ListTile(
      leading: icon,
      title: Text(
        heading,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Text(
        tail,
        style: TextStyle(fontSize: 16.0),
      ),
      onTap: () {},
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Container(
            height: 40.0,
            child: ListTile(
              title: Text(
                'Account',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            )),
        buildItem(Icon(Icons.email), 'Email', widget.email, () {}),
        buildBottom(),
        buildItem(Icon(Icons.person), 'Username', _username, () {}),
        buildBottom(),
        buildItem(Icon(Icons.assignment), 'Bio', _bio ?? 'little cabin', () {}),
        Container(
            height: 15,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  top: BorderSide(width: 1, color: Color(0xffe5e5e5)),
                  bottom: BorderSide(width: 1, color: Color(0xffe5e5e5)),
                ))),
      ],
    );
  }
}
