import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

// 用于本地消息缓存
class UserMessage {
  final int chatType;
  String messageType;
  String messageBody;
  int creatorId;
  int recipientId;
  int recipientGroupId;
  int isRead; // 用户阅读消息后置为1，默认为0，用于信息数提示
  int isOnline; // 用于区分在线消息与离线消息， 默认为1
  int isDelete; // 删除message item后置为1， 默认为0
  final int createAt;
  int expiredAt;

  UserMessage(
      {@required this.chatType,
      @required this.messageType,
      @required this.messageBody,
      @required this.creatorId,
      this.recipientId = 0,
      this.recipientGroupId = 0,
      this.isRead = 1,
      this.isOnline = 1,
      this.isDelete = 0,
      int createAt,
      int expiredAt})
      : this.createAt = createAt ?? DateTime.now().millisecondsSinceEpoch,
        this.expiredAt = expiredAt ?? 0;

  static List<UserMessage> allFromMapList(decodedJson) {
    return decodedJson
        // .cast<String, Friend>()
        .map((obj) => UserMessage.fromMap(obj))
        .toList()
        .cast<UserMessage>();
  }

  static UserMessage fromMap(Map map) {
    // print(map['creator_id'].runtimeType);
    return new UserMessage(
        chatType: map['chat_type'] as int,
        messageType: map["message_type"] as String,
        messageBody: map["message_body"] as String,
        creatorId: map["creator_id"] as int,
        recipientId: map["recipient_id"] ?? 0,
        recipientGroupId: map["recipient_group_id"] ?? 0,
        isRead: map['is_read'] ?? 1,
        isOnline: map['is_online'] ?? 1,
        isDelete: map['is_delete'] ?? 0,
        createAt: map["create_at"] as int,
        expiredAt: map["expired_at"] as int);
  }

  Map<String, dynamic> toMap() => {
        "chat_type": chatType,
        "message_type": messageType,
        "message_body": messageBody,
        "creator_id": creatorId,
        "recipient_id": recipientId,
        "recipient_group_id": recipientGroupId ?? 0,
        "is_read": isRead ?? 0,
        "is_online": isOnline ?? 1,
        "is_delete": isDelete ?? 0,
        "create_at": createAt,
        "expired_at": expiredAt
      };

  Map toJson() {
    print('toJson');
    return {
      "chat_type": chatType,
      "message_type": messageType,
      "message_body": messageBody,
      "creator_id": creatorId,
      "recipient_id": recipientId,
      "recipient_group_id": (recipientGroupId ?? 0),
      "is_read": (isRead ?? 0),
      "is_online": (isOnline ?? 1),
      "is_delete": (isDelete ?? 0),
      "create_at": createAt,
      "expired_at": expiredAt
    };
  }

  factory UserMessage.fromJson(dynamic json) {
    return UserMessage(
        chatType: json['chat_type'] as int,
        messageType: json["message_type"] as String,
        messageBody: json["message_body"] as String,
        creatorId: json["creator_id"] as int,
        recipientId: json["recipient_id"] as int,
        recipientGroupId: json["recipient_group_id"] as int,
        isRead: json['is_read'] as int,
        isOnline: json['is_online'] as int,
        isDelete: json['is_delete'] as int,
        createAt: json["create_at"] as int,
        expiredAt: json["expired_at"] as int);
  }

  @override
  String toString() {
    return '{ ${this.messageType}, ${this.messageBody}, ${this.creatorId}, ${this.recipientId}, ${this.createAt}, ${this.expiredAt} }';
  }
}
