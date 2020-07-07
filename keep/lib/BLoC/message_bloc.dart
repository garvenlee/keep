import 'dart:async';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/models/message.dart';
import 'package:keep/BLoC_provider/bloc_provider.dart';
// import 'package:keep/data/provider/user_provider.dart';
// import 'package:keep/data/provider/friend_provider.dart';

class MessageBloc extends BlocBase {
  //Get instance of the Repository
  final _msgRepository = MessageRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _msgController = StreamController<List<Message>>.broadcast();

  Stream<List<Message>> get messages => _msgController.stream;

  MessageBloc() {
    getMessages();
  }

  getMessages() async {
    _msgController.sink.add(await _msgRepository.getAllMessages());
  }

  addMessage(UserMessage msg) async {
    await _msgRepository.insertMessage(msg);
    // getMessages();
  }

  addAllMessages(List<UserMessage> msg) async {
    await _msgRepository.insertAllMessage(msg);
    // getMessages();
  }

  getMessage({int createAt, int creatorId}) async =>
      await _msgRepository.getMessage(createAt: createAt, creatorId: creatorId);

  deleteMessage(int createAt, int creatorId) async {
    await _msgRepository.deleteMessage(createAt, creatorId);
    // getMessages();
  }

  deleteMessages(List<UserMessage> messages) async {
    await _msgRepository.deleteMessages(messages);
  }

  // isRead
  updateMessage({UserMessage msg}) async {
    await _msgRepository.updateMessage(msg: msg);
    // getMessages();
  }

  // updateMessageOverIsRead(int chatType, int recipientId) async {
  //   await _msgRepository.updateMessageOverIsRead(chatType: chatType, recipientId: recipientId);
  // }

  void dispose() {
    _msgController.close();
  }
}
