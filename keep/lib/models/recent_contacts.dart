import 'dart:convert';

class RecentContacts {
  int id;
  int userOneId;
  int userTwoId;

  RecentContacts({
    this.id,
    this.userOneId,
    this.userTwoId
  });

  factory RecentContacts.fromMap(Map<String, dynamic> json) => new RecentContacts(
        id: json["id"] as int,
        userOneId: json["user_one_id"] as int,
        userTwoId: json["user_two_id"] as int,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_one_id": userOneId,
        "user_two_id": userTwoId,
      };

  static RecentContacts recentContactsFromJson(String str) {
    final jsonData = json.decode(str);
    return RecentContacts.fromMap(jsonData);
  }

  static String recentContactsToJson(RecentContacts data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }
}

class RecentGroups {
  int id;
  int userId;
  int groupId;

  RecentGroups({
    this.id,
    this.userId,
    this.groupId,
  });

  factory RecentGroups.fromMap(Map<String, dynamic> json) => new RecentGroups(
        id: json["id"] as int,
        userId: json["user_id"] as int,
        groupId: json["group_id"] as int,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId,
        "group_id": groupId,
      };

  static RecentGroups recentGroupsFromJson(String str) {
    final jsonData = json.decode(str);
    return RecentGroups.fromMap(jsonData);
  }

  static String recentGroupsToJson(RecentGroups data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }
}
