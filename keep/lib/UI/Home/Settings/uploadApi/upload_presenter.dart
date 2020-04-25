import 'dart:io';
import 'package:keep/data/rest_ds.dart';

abstract class SettingScreenContract {
  void onUploadSuccess(String hintTxt);
  void onUploadError(String errorTxt);
}

class SettingScreenPresenter {
  SettingScreenContract _view;
  // RestDatasource 用于向服务器端请求数据
  RestDatasource api = new RestDatasource();
  SettingScreenPresenter(this._view);

  // 发起请求并用于捕捉异常
  doUpload(File file, int userId) async {
    api.upload(file, userId).then((String hintText) {
      print('success.........................');
      _view.onUploadSuccess(hintText);
    }).catchError((Object error) {
      print('failed...........................');
      _view.onUploadError(error.toString());
    });
  }
}
