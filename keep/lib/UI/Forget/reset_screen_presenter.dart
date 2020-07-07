import 'package:keep/service/rest_ds.dart';
import 'package:keep/data/sputil.dart';

abstract class ResetScreenContract {
  void onResetSuccess(String username);
  void onResetError(String errorTxt);
  void onCheckSuccess(String code);
  void onCheckError(String errorTxt);
}

class ResetScreenPresenter {
  ResetScreenContract _view;
  // RestDatasource 用于向服务器端请求数据
  RestDatasource api = new RestDatasource();
  ResetScreenPresenter(this._view);

  // 发起请求并用于捕捉异常
  doReset(String username, String password, String code) {
    String _code = SpUtil.getString('verification_code');
    if (_code == code){
      api.reset(username, password).then((String username) {
      print(username);
      _view.onResetSuccess(username);
      // print('login success');
    }).catchError((Object error) {
      _view.onResetError(error.toString());});
    } else {
      _view.onCheckError("Your verification code is incorrect!");
    }
  }

  // 发起请求并用于捕捉异常
  doCheck(String email) {
    api.check(email).then((String code) {
      print('check enter......................');
      _view.onCheckSuccess(code.toString());
    }).catchError((Object error) {
      print('error????????????????????????????');
      _view.onCheckError(error.toString());});
  }
}