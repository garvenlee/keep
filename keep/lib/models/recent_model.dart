import 'package:keep/models/friend.dart';
import 'package:keep/models/group.dart';


class RecentModel {
  final int userType;
  final Friend user;
  final Group group;
  final int lastSeenTime;
  RecentModel(
      {this.userType, this.user, this.group, this.lastSeenTime});

  get name => userType == 1 ? user.pickname : group.roomName;
  get account => userType == 1 ? user.email : group.roomNumber;
  get avatar => userType == 1 ? user.avatar : group.roomAvatarObj;

  @override
  String toString() {
    return '{ ${this.userType}, ${this.lastSeenTime} }';
  }
}
