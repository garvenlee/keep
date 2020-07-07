import 'package:keep/service/rest_ds.dart';
// import 'package:keep/models/user.dart';

abstract class RegisterScreenContract {
  void onRegisterSuccess(String hintTxt);
  void onRegisterError(String errorTxt);
}

class RegisterScreenPresenter {
  RegisterScreenContract _view;
  // RestDatasource 用于向服务器端请求数据
  RestDatasource api = new RestDatasource();
  RegisterScreenPresenter(this._view);

  // 发起请求并用于捕捉异常
  doRegister(String username, String email, String password, String phone) {
    api.register(username, email, password, phone).then((Object hintTxt) {
      _view.onRegisterSuccess(hintTxt.toString());
      print('Register success');
    }).catchError((Object error) {
      _view.onRegisterError(error.toString());});
  }
}