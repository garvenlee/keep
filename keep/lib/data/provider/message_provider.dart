import 'package:keep/models/message.dart';
import 'package:keep/utils/sputil.dart';

class MessageProvider {
  static List<Message> _messages = <Message>[];

  static saveMessage(Message msg){
    msg.isRead = 0;
    _messages.add(msg);
    // SpUtil.remove("offline_message");
    SpUtil.putObjectList("offline_message", _messages);
  }

  static getMessages() {
    return _messages.length > 0
        ? _messages
        : SpUtil.getObjList("offline_message", Message.fromMap);
  }

  static getMessageByReId(int toUserId) {
    List<Message> messages = getMessages();
    List<Message> aimMsg = <Message>[];
    messages.forEach((message) { 
      if(message.recipientId == toUserId) {
        aimMsg.add(message);
      }
    });
    // 降序
    aimMsg.sort((left,right)=>(left.createAt > right.createAt ? 0: 1));
    print(aimMsg);
    return aimMsg;
  }

  static delete(int createAt) {
    List<Message> messages = getMessages();
    messages.removeWhere((msg) => msg.createAt == createAt);
    SpUtil.remove('offline_message');
    SpUtil.putObjectList("offline_message", messages);
    // print(_messages);
  }
}
