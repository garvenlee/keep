import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:keep/utils/tools_function.dart';

class Friend {
  Friend({
    @required this.userId,
    @required this.username,
    @required this.email,
    @required String base64Text,
    this.location,
    this.pickname,
    this.bio,
    this.phone = 'do not set'
  })  : this.base64Text = base64Text,
        this.avatar = base64Text == 'null' ? 'null' : txt2Image(base64Text);

  final int userId;
  Object avatar;
  final String bio;
  final String pickname;
  final String username;
  final String email;
  final String location;
  final String phone;
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
    return new Friend(
        userId: map['userId'] as int,
        username: '${capitalize(name)}',
        email: map['email'],
        phone: map['phone'] ?? 'do not set',
        base64Text: map['avatar'],
        pickname: map['pickname'] ?? '');
  }

  Map toJson() {
    // print('toJson');
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': base64Text,
      'pickname': pickname
    };
  }

  factory Friend.fromJson(dynamic json) {
    return Friend(
        userId: json['userId'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        base64Text: json['avatar'] as String,
        pickname: json['pickname'] as String);
  }

  @override
  String toString() {
    return '{ ${this.username}, ${this.email} }';
  }
}
