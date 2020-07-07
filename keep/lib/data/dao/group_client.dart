import 'dart:async';
import 'package:keep/data/database_helper.dart';
import 'package:keep/models/group_client.dart';

class GroupClientDao {
  final dbProvider = DatabaseHelper();

  //Adds new note records
  Future<int> createGroupClient(GroupClient client) async {
    final db = await dbProvider.db;
    var result = db.insert(roomClientTable, client.toJson());
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<GroupClient>> getGroupClients(
      {List<String> columns, String whereString, List<String> query}) async {
    final db = await dbProvider.db;
    // print(whereString);
    List<Map<String, dynamic>> result;
    if (query != null && query.length > 0) {
      result = await db.query(roomClientTable,
          columns: columns,
          where: whereString,
          whereArgs: query,
          orderBy: 'state DESC');
    } else {
      result = await db.query(roomClientTable, columns: columns);
    }
    // print(result);
    List<GroupClient> notes = result.isNotEmpty
        ? result.map((item) => GroupClient.fromJson(item)).toList()
        : [];
    return notes;
  }

  Future<List<GroupClient>> getGroupClientsById(int roomId) async {
    final db = await dbProvider.db;
    var result = await db
        .rawQuery('SELECT * FROM $roomClientTable WHERE room_id = $roomId');
    List<GroupClient> clients = [];
    // print('get room clients ===================>');
    // print(result);
    // print(result[0]['join_at']);
    if (result.isNotEmpty) {
      result.forEach((item) {
        clients.add(GroupClient.fromMap(item));
      });
    }
    // print(clients);
    return clients;
  }

  Future<GroupClient> getGroupClientById(int roomId, int userId) async {
    final db = await dbProvider.db;
    var result = await db.rawQuery(
        'SELECT * FROM $roomClientTable WHERE room_id = $roomId and user_id == $userId');
    return result.isNotEmpty ? GroupClient.fromMap(result[0]) : null;
  }

  Future updateMember(GroupClient client) async {
    final db = await dbProvider.db;
    await db.update(roomClientTable, client.toJson(),
        where: 'room_id = ? and user_id = ?',
        whereArgs: [client.roomId, client.userId]);
  }
}
