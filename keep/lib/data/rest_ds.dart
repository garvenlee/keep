import 'dart:async';

import 'package:keep/utils/network_util.dart';
import 'package:keep/models/user.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = "http://192.168.124.20:42300/user";
  static final loginURL = baseURL + "/login";
  static final registerURL = baseURL + "/register";
  static final checkURL = baseURL + "/forget";
  static final resetURL = baseURL + "/reset";
  // static final _apiKey = "somerandomkey";

  Future<User> login(String email, String password) {
    return _netUtil.post(loginURL, body: {
      // "api_key": _apiKey,
      "email": email,
      "password": password
    }).then((dynamic res) {
      if(res["error"]) {
        throw new Exception(res["error_msg"]);
        }
      return new User.map(res["user"]);
    });
  }

  Future<String> register(String username, String email, String password) {
    return _netUtil.post(registerURL, body: {
      "username": username,
      "email": email,
      "password": password
    }).then((dynamic res) {
      if(res["error"]) {
        throw new Exception(res["error_msg"]);
        }
      return res['hint_msg'];
    });
}

  Future<User> reset(String email, String password) {
    return _netUtil.post(resetURL, body: {
      "email": email,
      "password": password
    }).then((dynamic res) {
      if(res["error"]) {
        throw new Exception(res["error_msg"]);
        }
      return new User.map(res['user']);
    });}

  Future<String> check(String email) {
    return _netUtil.post(checkURL, body: {
      "email": email,
    }).then((dynamic res) {
      if(res["error"]) {
        throw new Exception(res["error_msg"]);
        }
      return res['verification_code'];
    });
 }
}