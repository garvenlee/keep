import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/widget/component_widget.dart' show buildGap;
import 'package:keep/widget/over_scroll.dart';
import 'package:keep/utils/utils_class.dart';
import 'package:keep/utils/tools_function.dart';
import '../FriendAvatar/friend_item.dart' show FriendItem;
import '../NewApi/upload_page.dart';

class AddGroupName extends StatefulWidget {
  final List<Friend> selFriends;
  AddGroupName({@required this.selFriends, key}) : super(key: key);

  @override
  _AddGroupNameState createState() => _AddGroupNameState(selFriends);
}

class _AddGroupNameState extends State<AddGroupName> {
  final textController;
  final scaffoldKey;
  final List<Friend> _selFriends;
  final int selNum;

  _AddGroupNameState(selFriends)
      : this._selFriends = selFriends,
        this.textController = new TextEditingController(),
        this.scaffoldKey = new GlobalKey<ScaffoldState>(),
        this.selNum = selFriends.length;

  String groupAvatar = '';

  Future<bool> _onPop(BuildContext context) {
    Navigator.pop(context, 'name');
    return Future.value(true);
  }

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

  // 裁剪图片应该是一个局部更新
  cropImage(BuildContext context, File file) async {
    await Navigator.push(context,
            MaterialPageRoute(builder: (context) => CropImageRoute(file)))
        .then((res) {
      if (res == null || res.stream['avatar'] == null)
        print('upload failed');
      else
        setState(() => groupAvatar = res.stream['avatar']);
    });
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _submit(BuildContext context, connectionStatus) {
    if (connectionStatus == ConnectivityStatus.Available) {
      // setState(() => _isLoading = true);
      if (groupAvatar.isEmpty || textController.text.isEmpty) {
        // _showSnackBar('Empty input is invalid.');
        showHintText('Empty input is invalid.');
        // setState(() => _isLoading = false);
      } else {
        Navigator.pop(
            context,
            UploadPopReceiver({
              'groupName': textController.text,
              'groupAvatar': groupAvatar
            }));
      }
    } else {
      _showSnackBar('Please check your internet.');
      // showHintText('Please check your internet.');
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
            child: WillPopScope(
      onWillPop: () => _onPop(context),
      child: Scaffold(
          key: scaffoldKey,
          body: ScrollConfiguration(
              behavior: OverScrollBehavior(),
              child: ListView(
                shrinkWrap: true,
                children: [
                  buildHeader(context), // 50.0
                  buildGroupProperty(context), // 90.0
                  buildGap(), // 15.0
                  buildMemberNum(),
                  buildMemberList(context)
                ],
              ))),
    )));
  }

  Widget buildHeader(BuildContext context) {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, _) {
      String headerText;
      if (connectionStatus == ConnectivityStatus.Available)
        headerText = 'Add GroupProperty';
      else
        headerText = 'Connecting...';
      return new Container(
          height: 50.0,
          decoration: BoxDecoration(color: Colors.blueGrey),
          padding: new EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(headerText,
                      style: TextStyle(
                          // color: Colors.white70,
                          fontSize: 16.0))),
              Container(
                  height: 40.0,
                  width: MediaQuery.of(context).size.width * 0.3,
                  padding: const EdgeInsets.all(5.0)),
              Container(
                  width: MediaQuery.of(context).size.width * 0.15 - 10.0,
                  child: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.done),
                      onPressed: () => _submit(context, connectionStatus)))
            ],
          ));
    });
  }

  Widget buildGroupProperty(BuildContext context) {
    return Container(
      height: 108.0,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [buildPicSel(context), buildTextField()],
      ),
    );
  }

  Widget buildMemberNum() {
    return selNum > 0
        ? Container(
            height: 20.0,
            child: Align(
                alignment: Alignment.center,
                child: Text(selNum.toString() + ' Member')),
          )
        : Container(height: 20.0);
  }

  Widget buildMemberList(BuildContext context) {
    return selNum > 0
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _selFriends.length,
            itemBuilder: (BuildContext context, int index) {
              return FriendItem(friend: _selFriends[index]);
            },
          )
        : Container(
            height: MediaQuery.of(context).size.height - 256.0,
            child: new Center(
                // child: new CircularProgressIndicator(),
                child: Text('There has not any members yet!')));
  }

  Widget buildPicSel(BuildContext context) {
    return groupAvatar.isEmpty || groupAvatar == 'null'
        ? CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white60,
            child: IconButton(
              icon: Icon(Icons.add_a_photo, size: 32),
              onPressed: () => customShowBottomSheet(context),
            ))
        : Container(
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
            child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => customShowBottomSheet(context),
                child: CircleAvatar(
                    radius: 32.0, backgroundImage: txt2Image(groupAvatar))));
  }

  Widget buildTextField() {
    return Container(
        width: MediaQuery.of(context).size.width - 32 * 2 - 20 * 3,
        height: 64,
        child: TextFormField(
          controller: textController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter Group Name',
            hintStyle: TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
        ));
  }

  customShowBottomSheet(BuildContext ctx) {
    return showModalBottomSheet(
        context: ctx,
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
                      cropImage(ctx, file);
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
                      cropImage(ctx, file);
                    }
                  });
                },
              ),
            ],
          );
        });
  }
}
