import 'dart:convert';
import 'package:keep/utils/tools_function.dart';

class RecentContact {
  int userOneId;
  int userTwoId;
  String userTwoEmail;
  String userTwoUsername;
  String userTwoPickname;
  String userTwoAvatarData;
  Object userTwoAvatar;
  int lastSeenTime;
  int isFriend; // 0 is false, 1 is true

  RecentContact(
      {this.userOneId,
      this.userTwoId,
      this.userTwoEmail,
      this.userTwoUsername,
      this.userTwoPickname,
      this.lastSeenTime,
      this.isFriend,
      String userTwoAvatarData})
      : this.userTwoAvatarData = userTwoAvatarData,
        this.userTwoAvatar =
            userTwoAvatarData == 'null' ? 'null' : txt2Image(userTwoAvatarData);

  factory RecentContact.fromMap(Map<String, dynamic> json) => new RecentContact(
      userOneId: json["user_one_id"] as int,
      userTwoId: json["user_two_id"] as int,
      userTwoEmail: json['user_two_email'] as String,
      userTwoUsername: json['user_two_username'] as String,
      userTwoPickname: json['user_two_pickname'] as String,
      userTwoAvatarData: json['user_two_avatar'] as String,
      lastSeenTime: json['last_seen_time'] as int,
      isFriend: json['is_friend'] as int);

  Map<String, dynamic> toMap() => {
        "user_one_id": userOneId,
        "user_two_id": userTwoId,
        "user_two_email": userTwoEmail,
        "user_two_username": userTwoUsername,
        "user_two_pickname": userTwoPickname,
        "user_two_avatar": userTwoAvatarData,
        "last_seen_time": lastSeenTime,
        "is_friend": isFriend
      };

  static RecentContact recentContactsFromJson(String str) {
    final jsonData = json.decode(str);
    return RecentContact.fromMap(jsonData);
  }

  static String recentContactsToJson(RecentContact data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }
}

class RecentGroup {
  int groupId;
  int groupSize;
  String groupName;
  String groupNumber;
  String groupAvatarData;
  Object groupAvatar;

  int userId;
  String username;
  String email;
  String userAvatarData;
  Object userAvatar;

  int lastSeenTime;
  int isAddIn;

  RecentGroup(
      {this.groupId,
      this.groupSize,
      this.groupName,
      this.groupNumber,
      String groupAvatarData,
      //
      this.userId,
      this.username,
      this.email,
      String userAvatarData,
      //
      this.lastSeenTime,
      this.isAddIn})
      : this.groupAvatarData = groupAvatarData,
        this.userAvatarData = userAvatarData,
        this.groupAvatar =
            groupAvatarData == 'null' ? 'null' : txt2Image(groupAvatarData),
        this.userAvatar =
            userAvatarData == 'null' ? 'null' : txt2Image(userAvatarData);

  factory RecentGroup.fromMap(Map<String, dynamic> json) => new RecentGroup(
      groupId: json["group_id"] as int,
      groupSize: json['group_size'] as int,
      groupName: json['group_name'] as String,
      groupAvatarData: json['group_avatar'] as String,
      groupNumber: json['group_number'] as String,
      userId: json["user_id"] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      userAvatarData: json['user_avatar'] as String,
      lastSeenTime: json['last_seen_time'] as int,
      isAddIn: json['is_add_in'] as int);

  Map<String, dynamic> toMap() => {
        "group_id": groupId,
        "group_size": groupSize,
        "group_name": groupName,
        "group_number": groupNumber,
        "group_avatar": groupAvatarData,
        "user_id": userId,
        "username": username,
        "email": email,
        "user_avatar": userAvatarData,
        "last_seen_time": lastSeenTime,
        "is_add_in": isAddIn
      };

  static RecentGroup recentGroupsFromJson(String str) {
    final jsonData = json.decode(str);
    return RecentGroup.fromMap(jsonData);
  }

  static String recentGroupsToJson(RecentGroup data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }
}
