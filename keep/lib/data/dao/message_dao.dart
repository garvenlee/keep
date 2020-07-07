import 'dart:async';
import 'package:keep/data/provider/friend_provider.dart';

import '../database_helper.dart';
import 'package:keep/models/message.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/models/group.dart';
import 'package:keep/models/group_client.dart';
import 'package:keep/data/dao/group_dao.dart';
import 'package:keep/data/dao/group_client.dart';
import 'package:keep/data/provider/user_provider.dart';
// import 'package:keep/data/provider/message_provider.dart';

class MessageDao {
  static final dbProvider = DatabaseHelper();
  static final groupDao = GroupDao();
  static final groupClientDao = GroupClientDao();

  //Adds new Todo records
  Future<int> createMessage(UserMessage msg) async {
    final db = await dbProvider.db;
    var result = db.insert(messageTable, msg.toMap());
    return result;
  }

  Future<int> createAllMessage(List<UserMessage> messages) async {
    final db = await dbProvider.db;
    messages.forEach((message) {
      db.insert(messageTable, message.toMap());
    });
    return Future.value(1);
  }

  Future<List<UserMessage>> getMessagesByRecvId(int chatType, int recvId,
      {bool isRead = false, bool isDelete = false}) async {
    final db = await dbProvider.db;
    List<Map<String, dynamic>> result;
    String whereString;
    List<String> query;
    List<UserMessage> messages;
    if (chatType == 1) {
      print('search userId is $recvId');
      print('is delete is $isDelete');
      whereString = '(creator_id = ? or recipient_id = ?)';
      query = [recvId.toString(), recvId.toString()];
    } else {
      whereString = 'recipient_group_id = ?';
      query = [(-recvId).toString()];
    }
    whereString = whereString + ' and is_delete = ?';
    query.add(isDelete ? '1' : '0');

    result = await db.query(messageTable, where: whereString, whereArgs: query);

    messages = result.isNotEmpty
        ? result.map((item) => UserMessage.fromMap(item)).toList()
        : [];
    messages.sort((left, right) => (left.createAt > right.createAt ? 1 : 0));
    return messages;
  }

  Future<UserMessage> getOneItem({int createAt, int creatorId}) async {
    final db = await dbProvider.db;
    List<Map<String, dynamic>> result = await db.query(messageTable,
        where: "create_at = ? and creator_id = ?",
        whereArgs: [createAt, creatorId]);
    return result.isNotEmpty ? UserMessage.fromMap(result[0]) : null;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<Message>> getAllMessages({bool isRead = true}) async {
    // print('get all messages from db===============>');
    final db = await dbProvider.db;

    List<Map<String, dynamic>> result;
    List<Message> messages = <Message>[];

    // isRead 表示当前是否是本地历史信息
    // 默认为0，表示当前获取的Message Item并没有被用户移除
    result = await db.rawQuery(isRead
        ? 'SELECT * FROM $messageTable where is_delete = 0 order by create_at ASC'
        : 'SELECT * FROM $messageTable where is_read = 0 order by create_at ASC');
    // ASC 升序，DESC 降序
    if (result.isEmpty) return messages;
    Map<int, List<UserMessage>> resMsgs = {};
    int selId;

    // print('get all messsages');
    int userId = UserProvider.getUserId();
    List<UserMessage> userMsgs =
        result.map((item) => UserMessage.fromMap(item)).toList();
    userMsgs.forEach((msg) {
      // print(msg.creatorId);
      selId = (msg.creatorId == userId
          ? (msg.chatType == 1 ? msg.recipientId : -msg.recipientGroupId)
          : msg.creatorId);
      if (resMsgs[selId] == null) {
        resMsgs[selId] = <UserMessage>[];
      }
      resMsgs[selId].add(msg);
    });
    var idKeys = resMsgs.keys.toList();
    // print(idKeys);
    for (var id in idKeys) {
      var userMsgs = resMsgs[id];
      print('handling message ==============> id: $id');
      Message msg;
      if (userMsgs[0].chatType == 1) {
        Friend friend = FriendProvider.getFriendById(id);
        msg = new Message(chatType: 1, messages: userMsgs, friend: friend);
      } else {
        print('query input roomId =================> ${-id}');
        Group group = await groupDao.getGroupById(-id);
        List<GroupClient> clients =
            await groupClientDao.getGroupClientsById(-id);
        Map<int, GroupClient> members = {};
        clients.forEach((client) => members[client.userId] = client);
        msg = new Message(
            chatType: 2, group: group, members: members, messages: userMsgs);
        // print(msg);
        // print('<================================');
      }
      messages.add(msg);
    }
    messages.forEach((message) {
      message.messages
          .sort((left, right) => (left.createAt > right.createAt ? 1 : 0));
    });
    return messages;
  }

  Future<int> deleteMessageById(int createAt, int creatorId) async {
    final db = await dbProvider.db;
    var result = await db.delete(messageTable,
        where: 'create_at = ? and creator_id = ?',
        whereArgs: [createAt, creatorId]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllMessages() async {
    final db = await dbProvider.db;
    var result = await db.delete(messageTable);
    return result;
  }

  Future deleteMessages(List<UserMessage> messages) async {
    final db = await dbProvider.db;
    messages.forEach((val) async {
      await db.rawQuery(
          'UPDATE $messageTable SET is_delete = 1 WHERE create_at = ?',
          [val.createAt]);
    });
    return Future.value(true);
  }

  // used to update the state of msg's num indicator
  Future updateMessage({UserMessage msg}) async {
    final db = await dbProvider.db;
    msg.isRead = 1;
    await db.update(messageTable, msg.toMap(),
        where: 'create_at = ? and creator_id = ?',
        whereArgs: [msg.createAt, msg.creatorId]);
  }
}
