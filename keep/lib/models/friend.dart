import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class Friend {
  Friend({
    @required this.avatar,
    @required this.name,
    @required this.email,
    this.location,
  });

  final Object avatar;
  final String name;
  final String email;
  final String location;

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
      var decodeTxt = Base64Decoder().convert(avatarData.split(',')[1]);
      avatar = MemoryImage(decodeTxt);
    } else {
      avatar = 'null';
    }

    return new Friend(
        avatar: avatar, name: '${_capitalize(name)}', email: map['email']);
  }

  static String _capitalize(String input) {
    return input.substring(0, 1).toUpperCase() + input.substring(1);
  }
}
