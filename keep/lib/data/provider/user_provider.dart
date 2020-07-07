import 'package:flutter/material.dart';
import 'package:keep/models/user.dart';
import 'package:keep/data/sputil.dart';
import 'package:keep/utils/tools_function.dart';

class UserProvider with ChangeNotifier {
  static String _username;
  static String _email;
  static int _userId;
  static String _apiKey;
  static String _avatar;
  static String _phone;
  static bool _isLogedIn = false;
  static Object _userAvatar;

  bool get isLogedIn => _isLogedIn || SpUtil.getBool('isLogedIn');
  String get email => _email ?? SpUtil.getString('email');
  String get username => _username ?? SpUtil.getString('username');
  String get avatar => _avatar ?? SpUtil.getString('avatar');
  String get phone => _phone ?? SpUtil.getString('phone');
  Object get userAvatar {
    if (_userAvatar == null) 
      _userAvatar = avatar == 'null' ? 'null' : txt2Image(avatar);
    return _userAvatar;
  }

  String get apiKey => _apiKey ?? SpUtil.getString('api_key');
  int get userId => _userId ?? SpUtil.getInt('user_id');
  User get user => new User(
      userId: userId,
      email: email,
      username: username,
      phone: phone,
      base64Txt: avatar,
      apiKey: apiKey);

  void updateUserPic(String avatar) {
    _avatar = avatar;
    _userAvatar = txt2Image(_avatar);
    SpUtil.remove('avatar');
    SpUtil.putString('avatar', avatar);
    notifyListeners();
  }

  static void saveUser(User user) {
    _username = user.username;
    _email = user.email;
    _phone = user.phone;
    _userId = user.userId;
    _apiKey = user.apiKey;
    _avatar = user.userPic;
    _userAvatar = user.avatar;
    _isLogedIn = true;
    // 以防万一，保存在本地
    SpUtil.putBool('isLogedIn', true);
    SpUtil.putInt('user_id', user.userId);
    SpUtil.putString('username', user.username);
    SpUtil.putString('email', user.email);
    SpUtil.putString('phone', user.phone);
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
    SpUtil.remove('phone');
    SpUtil.remove('api_key');
    SpUtil.remove('avatar');
    SpUtil.remove('isLogedIn');

    _userId = null;
    _username = null;
    _email = null;
    _phone = null;
    _apiKey = null;
    _avatar = null;
    _isLogedIn = false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
