import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep/UI/Home/Settings/upload_page.dart';
import 'package:keep/global/flush_status.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/utils/setting_header.dart';
import 'package:keep/utils/sputil.dart';
import 'user_panel.dart';
import 'user_info.dart';
import 'setting_item.dart';

class SettingMainPage extends StatefulWidget {
  final String _username;
  final String _email;
  final String _userPic;

  SettingMainPage(this._username, this._email, this._userPic);

  @override
  SettingMainPageState createState() => SettingMainPageState();
}

class SettingMainPageState extends State<SettingMainPage> {
  File file;
  BuildContext _ctx;
  String username;
  String userPic;
  bool _isUpgrade;

  Future<File> chooseGallery() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    return img;
  }

  Future<File> chooseCamara() async {
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    return img;
  }

  @override
  void initState() {
    this.username = widget._username;
    this.userPic = widget._userPic;
    this._isUpgrade = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    file?.delete();
  }

  void _submit() {
    showModalBottomSheet(
        context: _ctx,
        builder: (BuildContext context) {
          return new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.photo_camera),
                title: new Text("Camera"),
                onTap: () async {
                  chooseCamara().then((file) {
                    if (file != null) {
                      Navigator.of(context).pop();
                      cropImage(_ctx, file);
                    }
                  });
                },
              ),
              new ListTile(
                leading: new Icon(Icons.photo_library),
                title: new Text("Gallery"),
                onTap: () async {
                  chooseGallery().then((file) {
                    if (file != null) {
                      Navigator.of(context).pop();
                      cropImage(_ctx, file);
                    }
                  });
                },
              ),
            ],
          );
        });
  }

  cropImage(BuildContext context, File file) async {
    await Navigator.push<UploadPopReceiver>(
            context,
            MaterialPageRoute(
                builder: (context) => CropImageRoute(file, widget._username)))
        .then((res) {
      print(res);
      if (res == null || res.stream['hint_msg'].isEmpty) {
        print('upload failed');
        // showFlushBar(context, widget._username, 'Empty Opration',
        //     iconIndicator['error']);
      } else {
        setState(() {
          this.userPic = res.stream['avatar'];
          this._isUpgrade = true;
        });
        SpUtil.putString('userPic', res.stream['avatar']);
        SpUtil.putBool('isUpgrade', true);
        // print(res.stream['avatar']);
        print('success.....');
        showFlushBar(context, widget._username, res.stream['hint_msg'],
            iconIndicator['success']);
      }
    });
  }

  Widget buildButton() {
    return Container(
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
        margin: EdgeInsets.only(top: 150.0, left: 320.0),
        child: CircleAvatar(
          radius: 28.0,
          backgroundColor: Colors.white,
          child: Container(
              child: IconButton(
                  icon:
                      Icon(Icons.photo_camera, color: Colors.grey, size: 28.0),
                  onPressed: _submit)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return WillPopScope(
        child: Scaffold(
          body: Stack(children: [
            Container(
                child: ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                SettingHeader(),
                UserPanel(this.username, widget._email, this.userPic),
                UserInfo(),
                SettingItems()
              ],
            )),
            buildButton(),
          ]),
        ),
        onWillPop: () {
          Navigator.pop(
              _ctx,
              UpgradeUserPic(
                  {"avatar": this._isUpgrade ? this.userPic : 'null'}));
        });
  }
}
