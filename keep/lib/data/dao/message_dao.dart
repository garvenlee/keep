import 'dart:async';
import '../database_helper.dart';
import 'package:keep/models/message.dart';
import 'package:keep/data/provider/user_provider.dart';

class MessageDao {
  final dbProvider = DatabaseHelper();

  //Adds new Todo records
  Future<int> createMessage(Message msg) async {
    final db = await dbProvider.db;
    var result = db.insert('Message', msg.toMap());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<Map<int, List<Message>>> getMessages(
      {List<String> columns, String whereString, String query}) async {
    final db = await dbProvider.db;

    List<Map<String, dynamic>> result;
    Map<int, List<Message>> _messages = {};
    if (query != null) {
      if (query.isNotEmpty) {
        result = await db.query('Message',
            columns: columns, where: whereString, whereArgs: ["$query"]);
        List<Message> msgs = result.isNotEmpty
            ? result.map((item) => Message.fromMap(item)).toList()
            : [];
        _messages = {int.parse(query): msgs};
      }
    } else {
      // result = await db.query('Message', columns: columns);
      result =
          await db.rawQuery('SELECT * FROM Message order by create_at ASC');
      // ASC 升序，DESC 降序
      List<Message> msgs = result.isNotEmpty
          ? result.map((item) => Message.fromMap(item)).toList()
          : [];
      int _userId = UserProvider.getUserId();
      int selId;
      msgs.forEach((msg) {
        selId = (msg.creatorId == _userId ? msg.recipientId : msg.creatorId);
        if (_messages[selId] == null) {
          _messages[selId] = <Message>[];
        }
        _messages[selId].add(msg);
      });
    }
    return _messages;
  }

  //Delete Todo records
  Future<int> deleteMessageById(int createAt, int creatorId) async {
    final db = await dbProvider.db;
    var result = await db.delete('Message',
        where: 'create_at = ? and creator_id = ?',
        whereArgs: [createAt, creatorId]);

    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllMessages() async {
    // final db = await dbProvider.db;
    // var result = await db.delete(
    //   'Message',
    // );

    // return result;
  }
}
