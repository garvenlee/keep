import 'chat_message.dart';
import 'group.dart';
import 'group_client.dart';
import 'friend.dart';

class Message {
  final int chatType;
  final List<UserMessage> messages;
  final Friend friend;
  final Group group;
  final Map<int, GroupClient> members;
  int msgNum = -1;
  int offlineMsgNum = -1;
  int isOfflineFlag = -1;
  Message(
      {this.chatType, this.messages, this.friend, this.group, this.members});

  get to => chatType == 1 ? friend?.userId : group?.roomId;
  get avatar => chatType == 1 ? friend?.avatar : group?.roomAvatarObj;
  get name => chatType == 1 ? friend?.username : group?.roomName;
  get userId => chatType == 1 ? friend?.userId : group?.roomId;
  get msgHintNum => calHintNum();
  get offlineFlag {
    if (isOfflineFlag == 1) return true;
    bool isOffline = false;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].isOnline == 0) {
        isOffline = true;
        isOfflineFlag = 1;
        break;
      }
    }
    if (!isOffline) isOfflineFlag = 0;
    return isOffline;
  }

  int calHintNum() {
    if (msgNum >= 0) return msgNum;
    int num = 0;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isRead == 0 &&
          ((messages[i].chatType == 1 && messages[i].creatorId == userId) ||
              messages[i].chatType == 2 && messages[i].creatorId != userId))
        num += 1;
    }
    msgNum = num;
    // print(msgNum);
    return num;
  }

  get offlineMsgHintNum => calOfflineHintNum();

  int calOfflineHintNum() {
    if (offlineMsgNum >= 0) return offlineMsgNum;
    int num = 0;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isOnline == 0) num += 1;
    }
    offlineMsgNum = num;
    return num;
  }

  @override
  String toString() {
    print('chatType: ${this.chatType}');
    print('friend is null: ${this.friend == null}');
    print('group is null: ${this.group == null}');
    return '{ ${this.chatType}, ${this.messages.length} }';
  }
}
