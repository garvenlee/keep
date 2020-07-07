import 'package:keep/utils/tools_function.dart';

class User {
  int userId;
  String email;
  String password;
  String username;
  String phone;
  String apiKey;
  String userPic;
  Object avatar;
  User(
      {this.userId,
      this.email,
      this.password,
      this.username,
      this.apiKey,
      String base64Txt,
      this.phone = 'do not set'}) : 
      this.userPic = base64Txt,
      this.avatar = base64Txt == 'null' ? 'null' : txt2Image(base64Txt);

  User.map(dynamic obj) {
    this.userId = int.parse(obj['user_id']);
    this.email = obj["email"];
    this.password = obj["password"] ?? "hey, you don't know";
    this.username = obj["username"];
    this.apiKey = obj["api_key"] ?? "You don't know";
    this.userPic = obj["user_pic"];
    this.phone = obj["phone"] ?? 'do not set';
  }

  static User fromMap(Map map) {
    return new User(
        userId: int.parse(map['user_id']),
        email: map['email'],
        password: map['password'] ?? 'You do not know',
        username: capitalize(map['username']),
        phone: map['phone'] ?? 'do not set',
        apiKey: map['api_key'],
        base64Txt: map['user_pic']);
  }

  Map toJson() {
    print('toJson');
    return {
      'user_id': userId.toString(),
      'email': email,
      'password': password,
      'username': username,
      'phone': phone,
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
        phone: json['phone'] as String,
        apiKey: json['api_key'] as String,
        base64Txt: json['user_pic'] as String);
  }
}
