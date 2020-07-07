import 'package:flutter/material.dart';
import 'package:keep/models/message.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/data/provider/user_provider.dart';

class MessagesProvider with ChangeNotifier {
  List<Message> _messages;
  static List<int> _receiverId;
  static final int userId = UserProvider.getUserId();

  static final MessagesProvider _instance = MessagesProvider.internal();
  MessagesProvider.internal();
  factory MessagesProvider([List<Message> messages]) {
    if (_instance._messages == null) _instance._messages = messages;
    return _instance;
  }

  int get total1 => _messages != null ? _messages.length : 0;
  int get total2 {
    if (_messages == null) return 0;
    int number = 0;
    _messages.forEach((val) {
      number += val.messages.length;
    });
    return number;
  }

  List<Message> get messages => _messages;
  get receiverId {
    if (_receiverId != null && _receiverId.isNotEmpty) return _receiverId;
    _receiverId = getDataFromMessages(_messages);
    return _receiverId;
  }

  static getDataFromMessages(messages) {
    messages.forEach((val) {
      _receiverId.add(val.userId);
    });
  }

  addMessage(Message value) {
    _messages.add(value);
    _receiverId.add(value.userId);
    notifyListeners();
  }

  addUserMessage(UserMessage value) {
    int toIndex = _receiverId.indexOf(value.chatType == 1
        ? value.creatorId != userId ? value.creatorId : value.recipientId
        : 0);
    _messages[toIndex].messages.add(value);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// class MessageProviderManager {
//   MessagesProvider _todosProvider;

//   static final MessageProviderManager _instance = MessageProviderManager.internal();
//   MessageProviderManager.internal();
//   factory MessageProviderManager([MessagesProvider provdier]) {
//     if(_instance._todosProvider == null)
//       _instance._todosProvider = provider;
//     return _instance;
//   }

//   MessagesProvider get provider {
//     // print('get db======================================>');
//     if (_todosProvider != null) return _todosProvider;
//     // print('_db is null');
//     _todosProvider = MessagesProvider([]);
//     return _todosProvider;
//   }

//   set provdier(MessagesProvider provider) {
//     _todosProvider = provider;
//   }
// }
