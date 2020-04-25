import 'dart:convert';

// 用于本地消息缓存
class Message {
  int chatType;
  String messageType;
  String messageBody;
  int creatorId;
  int recipientId;
  int recipientGroupId;
  int isRead; // 判断是否是离线消息，未发出，服务器端表示是否接收
  int createAt;
  int expiredAt;

  Message(
      {this.chatType,
      this.messageType,
      this.messageBody,
      this.creatorId,
      this.recipientId,
      this.recipientGroupId,
      this.isRead,
      this.createAt,
      this.expiredAt});

  static Message fromMap(Map map) {
    print(map['creator_id'].runtimeType);
    return new Message(
        chatType: map['chat_type'] as int,
        messageType: map["message_type"] as String,
        messageBody: map["message_body"] as String,
        creatorId: map["creator_id"] as int,
        recipientId: map["recipient_id"] ?? 0,
        recipientGroupId: map["recipient_group_id"] ?? 0,
        isRead: map['is_read'] ?? 1,
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
        "is_read": isRead ?? 1,
        "create_at": createAt,
        "expired_at": expiredAt
      };

  static Message messageFromJson(String str) {
    final jsonData = json.decode(str);
    print('message from json processing.......................');
    return Message.fromMap(jsonData);
  }

  static String messageToJson(Message data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  Map toJson() {
    print('toJson');
    return {
      "chat_type": chatType,
      "message_type": messageType,
      "message_body": messageBody,
      "creator_id": creatorId,
      "recipient_id": recipientId,
      "recipient_group_id": (recipientGroupId ?? 0),
      "is_read": (isRead ?? 1),
      "create_at": createAt,
      "expired_at": expiredAt
    };
  }

  factory Message.fromJson(dynamic json) {
    return Message(
        chatType: json['chat_type'] as int,
        messageType: json["message_type"] as String,
        messageBody: json["message_body"] as String,
        creatorId: json["creator_id"] as int,
        recipientId: json["recipient_id"] as int,
        recipientGroupId: json["recipient_group_id"] as int,
        isRead: json['is_read'] as int,
        createAt: json["create_at"] as int,
        expiredAt: json["expired_at"] as int);
  }

  @override
  String toString() {
    return '{ ${this.messageType}, ${this.messageBody}, ${this.creatorId}, ${this.recipientId}, ${this.createAt}, ${this.expiredAt} }';
  }
}
