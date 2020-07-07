import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep/UI/Home/Settings/uploadApi/upload_page.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/widget/flush_status.dart';
import 'package:keep/widget/component_widget.dart';
import 'package:provider/provider.dart';
import 'package:keep/utils/utils_class.dart';
import 'settingUI/user_panel.dart';
import 'settingUI/user_info.dart';
import 'settingUI/setting_item.dart';
import 'package:keep/settings/selection_config.dart';
import 'package:keep/settings/status_config.dart';

class SettingMainPage extends StatefulWidget {
  @override
  SettingMainPageState createState() => SettingMainPageState();
}

class SettingMainPageState extends State<SettingMainPage> {
  GlobalKey<UserPanelState> _key = GlobalKey();
  String dropdownValue = 'default';
  BuildContext _ctx;

  Future<File> chooseGallery() async {
    // ignore: deprecated_member_use
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    return img;
  }

  Future<File> chooseCamara() async {
    // ignore: deprecated_member_use
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    return img;
  }

  cropImage(BuildContext context, File file, String username) async {
    await Navigator.push<UploadPopReceiver>(context,
            MaterialPageRoute(builder: (context) => CropImageRoute(file)))
        .then((res) {
      if (res == null || res.stream['hint_msg'].isEmpty) {
        print('upload failed');
      } else {
        // 局部刷新界面
        Provider.of<UserProvider>(context, listen: false)
            .updateUserPic(res.stream['avatar']);
        _key.currentState.setAvatar(UserProvider().userAvatar);

        // print('success.....');
        showFlushBar(context, username, res.stream['hint_msg'],
            iconIndicator['success']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Consumer<UserProvider>(builder: (context, user, child) {
      return Scaffold(
        body: Stack(children: [
          ListView(
            // physics: NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            children: <Widget>[
              Container(
                  color: Colors.blueGrey,
                  child: Column(children: [
                    buildHeader(),
                    UserPanel(
                        username: user.username,
                        email: user.email,
                        avatar: user.userAvatar,
                        key: _key),
                  ])),
              UserInfo(
                  username: user.username,
                  email: user.email,
                  phone: user.phone,
                  bio: null),
              buildGap(),
              SettingItems()
            ],
          ),
          buildButton(user.username),
        ]),
      );
    });
  }

  showBottomSheet(BuildContext context, String username) {
    return showModalBottomSheet(
        context: _ctx,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () async {
                  chooseCamara().then((file) {
                    if (file != null) {
                      Navigator.of(context).pop();
                      cropImage(_ctx, file, username);
                    }
                  });
                },
              ),
              new ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  chooseGallery().then((file) {
                    if (file != null) {
                      Navigator.of(context).pop();
                      cropImage(_ctx, file, username);
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  Widget buildButton(String username) {
    return Positioned(
        top: 150.0,
        left: MediaQuery.of(_ctx).size.width * 0.75,
        child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1.0, color: Colors.grey.withAlpha(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                  offset: Offset(0.3, 0.3),
                )
              ],
            ),
            // margin: EdgeInsets.only(top: 150.0, left: 320.0),
            child: CircleAvatar(
              radius: 28.0,
              backgroundColor: Colors.white,
              child: Container(
                  child: IconButton(
                      icon: const Icon(Icons.photo_camera,
                          color: Colors.grey, size: 28.0),
                      onPressed: () => showBottomSheet(context, username))),
            )));
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
                  onPressed: () => Navigator.pop(context))),
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
                    'Edit name',
                    'Log out',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        onTap: settingSelctionTapAction[value](_ctx),
                        value: value,
                        child: Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: settingSelection[value]),
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
}
