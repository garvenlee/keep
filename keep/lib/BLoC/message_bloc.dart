import 'dart:async';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/models/message.dart';
// import 'package:keep/data/provider/user_provider.dart';
// import 'package:keep/data/provider/friend_provider.dart';

class MessageBloc {
  //Get instance of the Repository
  final _msgRepository = MessageRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _msgController = StreamController<Map<int, List<Message>>>.broadcast();

  get messages => _msgController.stream;

  MessageBloc() {
    getMessages();
  }

  getMessages({String whereString, String query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _msgController.sink.add(await _msgRepository.getAllMessages(
        whereString: whereString, query: query));
  }

  addMessage(Message msg) async {
    await _msgRepository.insertMessage(msg);
    getMessages();
  }

  deleteMessage(int createAt, int creatorId) async {
    _msgRepository.deleteMessage(createAt, creatorId);
    getMessages();
  }

  dispose() {
    _msgController.close();
  }
}
