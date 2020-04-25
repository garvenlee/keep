import 'package:flutter/material.dart';

class SettingItems extends StatelessWidget {
  const SettingItems({Key key}) : super(key: key);

  Widget buildItem(Icon icon, String text, Function callback) {
    return Container(
        child: ListTile(
      leading: icon,
      title: Text(text, style: TextStyle(color: Colors.grey)),
      onTap: callback,
    ));
  }

  Widget buildBottomLine() {
    return Container(
        height: 0.5,
        margin: EdgeInsets.only(left: 64.0),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5)))));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Container(
            height: 40.0,
            child: ListTile(
              title: Text(
                'Settings',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            )),
        buildItem(
            Icon(Icons.notifications_none), 'Notifications and Sounds', () {}),
        buildBottomLine(),
        buildItem(Icon(Icons.chat_bubble_outline), 'Char Settings', () {}),
        buildBottomLine(),
        buildItem(Icon(Icons.devices), 'Devices', () {}),
        buildBottomLine(),
        buildItem(Icon(Icons.data_usage), 'Data Usage', () {}),
        buildBottomLine(),
        buildItem(Icon(Icons.help), 'Help', (){}),
        buildBottomLine(),
      ],
    );
  }
}
