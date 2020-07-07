import 'dart:async';
import 'package:keep/data/database_helper.dart';
import 'package:keep/models/recent_model.dart';
import 'package:keep/models/recent_contacts.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/models/group.dart';

class RecentDao {
  final dbProvider = DatabaseHelper();

  //Adds new note records
  Future<int> newRecentContact(RecentContact contact) async {
    final db = await dbProvider.db;
    var result = db.insert(recentContactTable, contact.toMap());
    return result;
  }

  Future<int> newRecentGroup(RecentGroup group) async {
    final db = await dbProvider.db;
    var result = db.insert(recentGroupTable, group.toMap());
    return result;
  }

  Future<List<RecentModel>> getRecentContacts(int userId) async {
    final db = await dbProvider.db;
    List<Map<String, dynamic>> rc = await db.rawQuery(
        'SELECT * FROM $recentContactTable WHERE user_one_id = ? and is_friend = 1', [userId]);
    List<Map<String, dynamic>> rg = await db.rawQuery(
        'SELECT * FROM $recentGroupTable WHERE user_id = ? and is_add_in = 1', [userId]);
    List<RecentModel> contactsList = <RecentModel>[];

    List<RecentContact> contacts =
        rc.map((item) => RecentContact.fromMap(item)).toList();
    List<RecentGroup> groups =
        rg.map((item) => RecentGroup.fromMap(item)).toList();
    contacts.forEach((item) {
      Friend friend = Friend(
          userId: item.userTwoId,
          username: item.userTwoUsername,
          pickname: item.userTwoPickname,
          email: item.userTwoEmail,
          base64Text: item.userTwoAvatarData);
      contactsList.add(RecentModel(
          userType: 1, user: friend, lastSeenTime: item.lastSeenTime));
    });
    groups.forEach((item) {
      Group group = new Group(
          roomId: item.groupId,
          roomName: item.groupName,
          roomNumber: item.groupNumber,
          roomSize: item.groupSize,
          roomAvatar: item.groupAvatarData,
          userId: item.userId,
          email: item.email,
          username: item.username,
          userAvatar: item.userAvatarData);
      contactsList.add(RecentModel(
          userType: 2, group: group, lastSeenTime: item.lastSeenTime));
    });

    contactsList.sort((a, b) => a.lastSeenTime > b.lastSeenTime ? 0 : 1);
    return contactsList;
  }
}
