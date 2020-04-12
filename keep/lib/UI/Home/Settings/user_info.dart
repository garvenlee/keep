import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({Key key}) : super(key: key);

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
        buildItem(Icon(Icons.email), 'Email', 'root@163.com', () {}),
        buildBottom(),
        buildItem(Icon(Icons.person), 'Username', 'root', () {}),
        buildBottom(),
        buildItem(Icon(Icons.assignment), 'Bio', 'little cabin', () {}),
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
