import 'package:keep/data/rest_ds.dart';
import 'package:keep/models/user.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(User user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  // RestDatasource 用于向服务器端请求数据
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);

  // 发起请求并用于捕捉异常
  doLogin(String username, String password) {
    api.login(username, password).then((User user) {
      _view.onLoginSuccess(user);
      print('login success');
    }).catchError((Object error) {
      _view.onLoginError(error.toString());});
  }
}