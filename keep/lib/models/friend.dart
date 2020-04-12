import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/utils/user_pic.dart';

class Friend {
  Friend({
    @required this.avatar,
    @required this.username,
    @required this.email,
    @required this.base64Text,
    this.location,
  });

  final Object avatar;
  final String username;
  final String email;
  final String location;
  final String base64Text;

  static List<Friend> allFromMapList(decodedJson) {
    return decodedJson
        // .cast<String, Friend>()
        .map((obj) => Friend.fromMap(obj))
        .toList()
        .cast<Friend>();
  }

  static Friend fromMap(Map map) {
    var name = map['username'];
    var avatarData = map['avatar'];
    var avatar;
    if (avatarData != 'null') {
      avatar = txt2Image(avatarData);
    } else {
      avatar = 'null';
      avatarData = 'null';
    }
    return new Friend(
        avatar: avatar, username: '${capitalize(name)}', email: map['email'],
        base64Text: avatarData);
  }

  Map toJson() {
    print('toJson');
    return {'username': username, 'email': email, 'avatar': base64Text};
  }

  factory Friend.fromJson(dynamic json) {
    return Friend(
        avatar: json['avatar'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        base64Text: json['avatar'] as String);
  }

  @override
  String toString() {
    return '{ ${this.username}, ${this.email} }';
  }
}
