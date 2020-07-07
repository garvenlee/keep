import 'package:keep/utils/tools_function.dart';

class Group {
  int roomId;
  String roomName;
  String roomNumber;
  int roomSize;
  String roomAvatar;
  int userId;
  String username;
  String email;
  String userAvatar;
  int createAt;
  Object roomAvatarObj;
  Group(
      {this.roomId,
      this.roomName,
      this.roomNumber,
      this.roomSize,
      String roomAvatar,
      this.userId,
      this.username,
      this.email,
      this.userAvatar,
      this.createAt})
      : this.roomAvatar = roomAvatar,
        this.roomAvatarObj =
            roomAvatar == 'null' ? 'null' : txt2Image(roomAvatar);

  Group.map(dynamic obj) {
    this.roomId = obj['room_id'] ?? 0;
    this.roomName = obj['room_name'];
    this.roomNumber = obj['room_number'];
    this.roomSize = obj['room_size'];
    this.roomAvatar = obj['room_avatar'];
    this.userId = obj['user_id'];
    this.email = obj["email"];
    this.username = obj["username"];
    this.userAvatar = obj['user_avatar'];
    this.createAt = obj['create_at'];
  }

  static Group fromMap(Map map) {
    return new Group(
        roomId: map['room_id'] ?? 0,
        roomName: map['room_name'],
        roomNumber: map['room_number'],
        roomSize: map['room_size'],
        roomAvatar: map['room_avatar'],
        userId: map['user_id'],
        username: map['username'],
        email: map['email'],
        userAvatar: map['user_avatar'],
        createAt: map['create_at']);
  }

  Map<String, dynamic> toJson() {
    // print('toJson');
    return {
      'room_id': roomId ?? 0,
      'room_name': roomName,
      'room_number': roomNumber,
      'room_size': roomSize,
      'room_avatar': roomAvatar,
      'user_id': userId,
      'username': username,
      'email': email,
      'user_avatar': userAvatar,
      'create_at': createAt
    };
  }

  factory Group.fromJson(dynamic json) {
    return Group(
        roomId: json['room_id'] as int,
        roomName: json['room_name'] as String,
        roomNumber: json['room_number'] as String,
        roomSize: json['room_size'] as int,
        roomAvatar: json['room_avatar'] as String,
        userId: json['user_id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        userAvatar: json['user_avatar'] as String,
        createAt: json['create_at'] as int);
  }
}
