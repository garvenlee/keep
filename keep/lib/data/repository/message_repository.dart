import 'package:keep/data/dao/message_dao.dart';
import 'package:keep/models/message.dart';

class MessageRepository {
  final msgDao = MessageDao();

  Future getAllMessages({String whereString, String query}) => msgDao.getMessages(whereString: whereString, query: query);

  Future insertMessage(Message msg) => msgDao.createMessage(msg);

  Future deleteMessage(int createAt, int creatorId) => msgDao.deleteMessageById(createAt, creatorId);

  //We are not going to use this in the demo
  Future deleteAllMessages() => msgDao.deleteAllMessages();
}