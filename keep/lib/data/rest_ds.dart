import 'dart:async';
import 'dart:convert';

import 'package:keep/utils/network_util.dart';
import 'package:keep/models/user.dart';
import 'package:keep/models/friend.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = "http://192.168.124.14:42300/user/";
  static final loginURL = baseURL + "login";
  static final registerURL = baseURL + "register";
  static final checkURL = baseURL + "forget";
  static final resetURL = baseURL + "reset";
  // static final _apiKey = "somerandomkey";

  Future<User> login(String email, String password) {
    print('login......');
    print(email + ' ' + password);
    return _netUtil
        .post(loginURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json"
            },
            body: json.encode({
              // "api_key": _apiKey,
              "email": email,
              "password": password
            }),
            encoding: Utf8Codec())
        .then((dynamic res) {
      print('error......');
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return new User.map(res["user"]);
    });
  }

  Future<String> register(String username, String email, String password) {
    return _netUtil
        .post(registerURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json"
            },
            body: json.encode(
                {"username": username, "email": email, "password": password}),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return res['hint_msg'];
    });
  }

  Future<User> reset(String email, String password) {
    return _netUtil
        .post(resetURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json"
            },
            body: json.encode({"email": email, "password": password}),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return new User.map(res['user']);
    });
  }

  Future<String> check(String email) {
    return _netUtil
        .post(checkURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json"
            },
            body: json.encode({
              "email": email,
            }),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return res['verification_code'];
    });
  }

  Future<List<Friend>> getFriends(String email) {
    String getFriendsURL = baseURL + email;
    print(getFriendsURL);
    return _netUtil.get(getFriendsURL).then((res) {
      print(res);
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return Friend.allFromMapList(res['friends']);
    });
  }
}
