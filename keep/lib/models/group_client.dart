import 'package:keep/utils/tools_function.dart';

class GroupClient {
  int roomId;
  int userId;
  String username;
  String email;
  String userAvatar;
  Object userAvatarObj;
  int joinAt;
  GroupClient(
      {this.roomId,
      this.userId,
      this.username,
      this.email,
      this.userAvatar,
      this.joinAt})
      : this.userAvatarObj =
            userAvatar != 'null' ? txt2Image(userAvatar) : 'null';

  GroupClient.map(dynamic obj) {
    this.roomId = obj['room_id'] ?? 0;
    this.userId = obj['user_id'];
    this.username = obj['username'];
    this.email = obj['email'];
    this.userAvatar = obj['user_avatar'];
    this.joinAt = obj['join_at'];
  }

  static GroupClient fromMap(Map map) {
    return new GroupClient(
        roomId: map['room_id'] ?? 0,
        userId: map['user_id'],
        username: map['username'],
        email: map['email'],
        userAvatar: map['user_avatar'],
        joinAt: map['join_at']);
  }

  Map<String, dynamic> toJson() {
    // print('toJson');
    return {
      'room_id': roomId ?? 0,
      'user_id': userId,
      'username': username,
      'email': email,
      'user_avatar': userAvatar,
      'join_at': joinAt
    };
  }

  factory GroupClient.fromJson(dynamic json) {
    return GroupClient(
        roomId: json['room_id'] as int,
        userId: json['user_id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        userAvatar: json['user_avatar'] as String,
        joinAt: json['join_at'] as int);
  }
}
