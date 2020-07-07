import 'package:flutter/material.dart';
import 'package:keep/UI/Home/Settings/settingUI/user_panel.dart';
import 'package:keep/UI/Home/Settings/settingUI/user_info.dart';
import 'package:keep/widget/component_widget.dart';
import 'package:keep/settings/selection_config.dart';
import 'package:keep/models/friend.dart';

class UserProfile extends StatefulWidget {
  final Friend user;
  UserProfile({this.user});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  BuildContext _ctx;
  String dropdownValue = 'default';
  GlobalKey<UserPanelState> _key = GlobalKey();

  Future<bool> _onPop(){
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
                  UserPanel(
                      username: widget.user.pickname,
                      email: widget.user.email,
                      avatar: widget.user.avatar,
                      key: _key),
                ])),
            UserInfo(
                username: widget.user.username,
                email: widget.user.email,
                phone: widget.user.phone,
                bio: null),
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
                  onPressed: () => Navigator.pop(context, false))),
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
}
