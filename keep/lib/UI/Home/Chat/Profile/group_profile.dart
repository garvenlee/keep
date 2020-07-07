import 'package:flutter/material.dart';
import 'package:keep/models/group_source.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:keep/widget/component_widget.dart';
import 'package:keep/settings/selection_config.dart';

class GroupProfile extends StatefulWidget {
  final GroupSource group;
  GroupProfile({this.group, Key key}) : super(key: key);

  @override
  _GroupProfileState createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  BuildContext _ctx;
  String dropdownValue = 'default';
  // GlobalKey<_GroupProfileState> _key = GlobalKey();

  Future<bool> _onPop() {
    Navigator.pop(_ctx, false);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
        body: WillPopScope(
      onWillPop: () => _onPop(),
      child: Stack(children: [
        ListView(
          // physics: NeverScrollableScrollPhysics(),
          // shrinkWrap: true,
          children: <Widget>[
            Container(
                color: Colors.blueGrey,
                child: Column(children: [
                  buildHeader(),
                  buildGroupPanel(
                      name: widget.group.group.roomName,
                      number: widget.group.group.roomNumber,
                      avatar: widget.group.group.roomAvatarObj),
                ])),
            buildGap(),
            userActionBtn()
          ],
        ),
        // buildButton(user.username),`
        Container()
      ]),
    ));
  }

  Widget buildHeader() {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(children: <Widget>[
          Flexible(
              flex: 3,
              child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(_ctx, false))),
          Flexible(
              flex: 10,
              child: Container(
                width: MediaQuery.of(_ctx).size.width * 0.4,
              )),
          Flexible(
              flex: 12,
              child: Container(
                  child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  // value: dropdownValue,
                  iconEnabledColor: Color(0xFF595959),
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                  ),
                  iconSize: 24,
                  elevation: 8,
                  isExpanded: true,
                  isDense: true,
                  // style: TextStyle(color: Colors.deepPurple),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: const <String>[
                    'Edit contact',
                    'Delete contact',
                    'Block contact'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        onTap: userProfileSelectionTapAction[value](),
                        value: value,
                        child: Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: userProfileSelection[value]),
                            Text(
                              value,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ));
                  }).toList(),
                )),
              )))
        ]));
  }

  Widget userActionBtn() {
    return ListView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          buildAddAction(),
          buildBottom(),
          buildCancelAction(),
          buildBottom()
        ]);
  }

  Widget buildAddAction() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
          height: 56.0,
          onPressed: () => Navigator.pop(_ctx, true),
          child: Center(
              child: Text("Add",
                  style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'NanumGothic',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0))),
        ));
  }

  Widget buildCancelAction() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
          height: 56.0,
          onPressed: () => Navigator.pop(_ctx, false),
          child: Center(
              child: Text("Cancel",
                  style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'NanumGothic',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0))),
        ));
  }

  Widget buildGroupPanel({name, number, avatar}) {
    return Container(
        height: 100.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        child: Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: buildAvatar(avatar),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(capitalize(name),
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 15.0),
                  Text(number,
                      style: TextStyle(fontSize: 14, color: Colors.white))
                ],
              )
            ]));
  }

  Widget buildAvatar(Object avatar) {
    return Container(
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          border: new Border.all(
              color: Colors.grey.withAlpha(20), width: 1.0), // 边色与边宽度
          color: Color(0xFF9E9E9E), // 底色
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 0.5,
              offset: Offset(0.3, 0.3),
            )
          ],
        ),
        child: CircleAvatar(radius: 32.0, backgroundImage: avatar));
  }
}
