import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/global/user_pic.dart';

class Friend {
  Friend({
    @required this.userId,
    @required this.avatar,
    @required this.username,
    @required this.email,
    @required this.base64Text,
    this.location,
  });

  final int userId;
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
    // print('enter.....................');
    // print(map);
    // print(map['userId'].runtimeType);
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
        userId: map['userId'] as int,
        avatar: avatar,
        username: '${capitalize(name)}',
        email: map['email'],
        base64Text: avatarData);
  }

  Map toJson() {
    // print('toJson');
    return {
      'userId': userId.toString(),
      'username': username,
      'email': email,
      'avatar': base64Text
    };
  }

  factory Friend.fromJson(dynamic json) {
    return Friend(
        userId: int.parse(json['userId']),
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
