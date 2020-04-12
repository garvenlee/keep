import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:keep/utils/network_util.dart';
import 'package:keep/models/user.dart';
import 'package:keep/models/friend.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = "http://192.168.124.15:42300/";
  static final userNamespace = 'user/';
  static final imageNamespace = 'image/';
  static final chatNamespace = 'chat/';

  static final loginURL = baseURL + userNamespace + "login";
  static final registerURL = baseURL + userNamespace + "register";
  static final checkURL = baseURL + userNamespace + "forget";
  static final resetURL = baseURL + userNamespace + "reset";
  static final userPicURL = baseURL + imageNamespace + 'upload';
  // static final _apiKey = "somerandomkey";

  Future<User> login(String email, String password) {
    print('login......');
    // print(email + ' ' + password);
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

  Future<String> reset(String email, String password) {
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
      return res['username'];
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
    String getFriendsURL = baseURL + userNamespace + email;
    print(getFriendsURL);
    return _netUtil.get(
      getFriendsURL,
      headers: {
        "content-type": "application/json",
        "accept": "application/json"
      },
    ).then((res) {
      print(res);
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      print(res['error']);
      return Friend.allFromMapList(res['friends']);
    });
  }

  Future<String> upload(File file) {
    String base64Image = base64Encode(file.readAsBytesSync());
    var nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
    print(userPicURL);
    return _netUtil
        .post(userPicURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json"
            },
            body: json.encode({
              "imageData": base64Image,
              "email": "root@163.com",
              "timestamp": nowTimeStamp,
            }),
            encoding: Utf8Codec())
        .then((res) {
      // print(res['error']);
      if (res["error"]) {
        print('throw error');
        throw new Exception(res["error_msg"]);
      }
      print('no error.....');
      return res['hint_msg'];
    });
  }
}
