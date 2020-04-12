import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:keep/global/global_tool.dart';
import 'upload_presenter.dart';

class CropImageRoute extends StatefulWidget {
  final String username;
  final File image; //原始图片路径
  CropImageRoute(this.image, this.username);

  @override
  _CropImageRouteState createState() => new _CropImageRouteState();
}

class _CropImageRouteState extends State<CropImageRoute>
    implements SettingScreenContract {
  double baseLeft; //图片左上角的x坐标
  double baseTop; //图片左上角的y坐标
  double imageWidth; //图片宽度，缩放后会变化
  double imageScale = 1; //图片缩放比例
  Image imageView;
  bool _isLoading = false;
  final cropKey = GlobalKey<CropState>();
  SettingScreenPresenter _presenter;
  BuildContext _ctx;
  File file;

  _CropImageRouteState() {
    _presenter = new SettingScreenPresenter(this);
  }

  @override
  void onUploadSuccess(String hintTxt) {
    setState(() => _isLoading = false);
    String base64Text = "data:image/jpg;base64," + base64Encode(file.readAsBytesSync());
    Navigator.pop(_ctx, UploadPopReceiver({'hint_msg': hintTxt, 'avatar': base64Text}));
  }

  @override
  void onUploadError(String errorTxt) {
    setState(() => _isLoading = false);
    Navigator.pop(_ctx, UploadPopReceiver({'hint_msg': '', 'avatar': 'null'}));
  }


  @override
  void dispose() {
    super.dispose();
    file?.delete();
  }


  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      width:  MediaQuery.of(context).size.width,
      // color: ThemeColors.color333333,
      color: Colors.grey,
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Crop.file(
              widget.image,
              key: cropKey,
              aspectRatio: 1.0,
              alwaysShowGrid: true,
            ),
          ),
          _isLoading
              ? new CircularProgressIndicator()
              : RaisedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _crop(widget.image);
                  },
                  child: Text('ok'),
                )
        ],
      ),
    ));
  }

  Future<void> _crop(File originalFile) async {
    final crop = cropKey.currentState;
    final area = crop.area;
    if (area == null) {
      print('crop failed');
    }
    await ImageCrop.requestPermissions().then((value) {
      if (value) {
        ImageCrop.cropImage(
          file: originalFile,
          area: crop.area,
        ).then((value) {
          setState(() {
            this.file = value;
          });
          upload(value);
        }).catchError((_) {
          print('crop failed');
        });
      } else {
        setState(() {
          this.file = originalFile;
        });
        upload(originalFile);
      }
    });
  }

  ///上传头像
  void upload(File file) {
    _presenter.doUpload(file);
  }
}
