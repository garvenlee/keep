import 'package:flutter/material.dart';
import 'package:keep/widget/component_widget.dart';

class UserInfo extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String bio;
  UserInfo({this.username, this.email, this.phone, this.bio, Key key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Container(
            height: 40.0,
            child: const ListTile(
              title: Text(
                'Account',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            )),
        buildItem(const Icon(Icons.person), 'Username', _username, () {}),
        buildBottom(),
        buildItem(const Icon(Icons.email), 'Email', widget.email, () {}),
        buildBottom(),
        buildItem(const Icon(Icons.phone_android), 'Phone', widget.phone ?? 'cannot see', () {}),
        buildBottom(),
        buildItem(const Icon(Icons.assignment), 'Bio', _bio ?? 'little cabin', () {}),
      ],
    );
  }
}
