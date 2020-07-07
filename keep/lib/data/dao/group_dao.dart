import 'dart:async';
import 'package:keep/data/database_helper.dart';
import 'package:keep/models/group.dart';

class GroupDao {
  final dbProvider = DatabaseHelper();


  //Adds new note records
  Future<int> createGroup(Group group) async {
    final db = await dbProvider.db;
    var result = db.insert(roomTable, group.toJson());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<Group>> getGroups(
      {List<String> columns, String whereString, List<String> query}) async {
    final db = await dbProvider.db;
    // print(whereString);
    List<Map<String, dynamic>> result;
    if (query != null && query.length > 0) {
      result = await db.query(roomTable,
          columns: columns,
          where: whereString,
          whereArgs: query,
          orderBy: 'state DESC');
    } else {
      result = await db.query(roomTable, columns: columns);
    }
    // print(result);
    List<Group> notes = result.isNotEmpty
        ? result.map((item) => Group.fromJson(item)).toList()
        : [];
    // print(notes);
    return notes;
  }

  Future<Group> getGroupById(int roomId) async{
    print('get group by id=======================> $roomId');
    final db = await dbProvider.db;
    var result = await db.rawQuery('SELECT * FROM $roomTable WHERE room_id = $roomId');
    return result.isNotEmpty ? 
      Group.fromMap(result[0])
      : null;
  }

  Future updateGroup(Group group) async {
    final db = await dbProvider.db;
    await db.update(roomTable, group.toJson(),
        where: 'room_id = ?',
        whereArgs: [group.roomId]);
  }
}
