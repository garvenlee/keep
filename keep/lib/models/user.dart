import 'package:keep/global/global_tool.dart';

class User {
  int userId;
  String email;
  String password;
  String username;
  String apiKey;
  String userPic;
  User(
      {this.userId,
      this.email,
      this.password,
      this.username,
      this.apiKey,
      this.userPic});

  User.map(dynamic obj) {
    this.userId = int.parse(obj['user_id']);
    this.email = obj["email"];
    this.password = obj["password"] ?? "hey, you don't know";
    this.username = obj["username"];
    this.apiKey = obj["api_key"] ?? "You don't know";
    this.userPic = obj["user_pic"];
  }

  static User fromMap(Map map) {
    return new User(
        userId: int.parse(map['user_id']),
        email: map['email'],
        password: map['password'] ?? 'You do not know',
        username: capitalize(map['username']),
        apiKey: map['api_key'],
        userPic: map['user_pic']);
  }

  Map toJson() {
    print('toJson');
    return {
      'user_id': userId.toString(),
      'email': email,
      'password': password,
      'username': username,
      'api_key': apiKey,
      'user_pic': userPic
    };
  }

  factory User.fromJson(dynamic json) {
    return User(
        userId: json['user_id'] as int,
        email: json['email'] as String,
        password: json['password'] as String,
        username: json['username'] as String,
        apiKey: json['api_key'] as String,
        userPic: json['user_pic'] as String);
  }
}
