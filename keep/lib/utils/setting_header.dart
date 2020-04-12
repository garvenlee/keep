import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/utils/sputil.dart';

class SettingHeader extends StatefulWidget {
  @override
  _SettingHeaderState createState() => new _SettingHeaderState();
}

class _SettingHeaderState extends State<SettingHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(children: <Widget>[
          IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                var isUpgrade = SpUtil.getBool('isUpgrade') ?? false;
                Navigator.pop(
                    context,
                    UpgradeUserPic({
                      "avatar": isUpgrade ? SpUtil.getString('userPic') : 'null'
                    }));
              }),
          Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.all(5.0)),
          IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
        ]));
  }
}
