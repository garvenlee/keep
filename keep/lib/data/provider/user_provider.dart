import 'package:flutter/material.dart';
import 'package:keep/models/user.dart';
import 'package:keep/utils/sputil.dart';


class UserProvider with ChangeNotifier {
  static String _username;
  static String _email;
  static int _userId;
  static String _apiKey;
  static String _avatar;
  static bool _isLogedIn = false;

  get isLogedIn => _isLogedIn;
  get email => _email ?? SpUtil.getString('email');
  get username => _username ?? SpUtil.getString('username');
  get avatar => _avatar ?? SpUtil.getString('avatar');
  get apiKey => _apiKey ?? SpUtil.getString('api_key');
  get userId => _userId ?? SpUtil.getInt('user_id');

  void updateUserPic(String avatar) {
    _avatar = avatar;
    SpUtil.remove('avatar');
    SpUtil.putString('avatar', avatar);
    notifyListeners();
  }

  static void saveUser(User user) {
    _username = user.username;
    _email = user.email;
    _userId = user.userId;
    _apiKey = user.apiKey;
    _avatar = user.userPic;
    _isLogedIn = true;
    // 以防万一，保存在本地
    SpUtil.putBool('isLogedIn', true);
    SpUtil.putInt('user_id', user.userId);
    SpUtil.putString('username', user.username);
    SpUtil.putString('email', user.email);
    SpUtil.putString('api_key', user.apiKey);
    SpUtil.putString('avatar', user.userPic);
    // notifyListeners();
  }

  static getUserId() {
    return _userId ?? SpUtil.getInt('user_id');
  }

  static getApiKey() {
    return _apiKey ?? SpUtil.getString('api_key');
  }

  static clearUser() {
    SpUtil.remove('user_id');
    SpUtil.remove('username');
    SpUtil.remove('email');
    SpUtil.remove('api_key');
    SpUtil.remove('avatar');
    SpUtil.remove('isLogedIn');

    _userId = null;
    _username = null;
    _email = null;
    _apiKey = null;
    _avatar = null;
    _isLogedIn = false;
  }
}
