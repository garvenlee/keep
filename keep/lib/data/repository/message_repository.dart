import 'package:keep/data/dao/message_dao.dart';
import 'package:keep/models/message.dart';
import 'package:keep/models/chat_message.dart';

class MessageRepository {
  final msgDao = MessageDao();

  Future<List<Message>> getAllMessages({bool isRead = true}) =>
      msgDao.getAllMessages(isRead: isRead);

  Future<List<UserMessage>> getMessagesByRecvId(int chatType, int recvId) =>
      msgDao.getMessagesByRecvId(chatType, recvId);

  Future<UserMessage> getMessage({int createAt, int creatorId}) =>
      msgDao.getOneItem(createAt: createAt, creatorId: creatorId);

  Future insertMessage(UserMessage msg) => msgDao.createMessage(msg);

  Future insertAllMessage(List<UserMessage> messages) => msgDao.createAllMessage(messages);

  Future deleteMessage(int createAt, int creatorId) =>
      msgDao.deleteMessageById(createAt, creatorId);

  //We are not going to use this in the demo
  Future deleteAllMessages() => msgDao.deleteAllMessages();

  Future deleteMessages(List<UserMessage> messages) => msgDao.deleteMessages(messages);

  Future updateMessage({UserMessage msg}) => msgDao.updateMessage(msg: msg);
}
