import 'dart:async';
import '../database_helper.dart';
import 'package:keep/models/storageUrl.dart';

class StorageUrlDao {
  final dbProvider = DatabaseHelper();

  Future<int> createStorageUrl(StorageUrl storage) async {
    final db = await dbProvider.db;
    var result = db.insert(storageTable, storage.toMap());
    return result;
  }

  Future<List<StorageUrl>> getStorageUrls(
      {List<String> columns, String whereString, String query}) async {
    final db = await dbProvider.db;

    List<Map<String, dynamic>> result;
    List<StorageUrl> storageUrls;
    if (query != null && query.isNotEmpty) {
      result = await db.query(storageTable,
          columns: columns, where: whereString, whereArgs: ["$query"]);
      storageUrls = result.isNotEmpty
          ? result.map((item) => StorageUrl.fromMap(item)).toList()
          : [];
    } else {
      result = await db.rawQuery('SELECT * FROM StorageUrl');
      storageUrls = result.isNotEmpty
          ? result.map((item) => StorageUrl.fromMap(item)).toList()
          : [];
    }
    return storageUrls;
  }

  Future<bool> getOneItem(String url) async {
    final db = await dbProvider.db;

    List<Map<String, dynamic>> result;

    result = await db.rawQuery("SELECT * FROM StorageUrl WHERE url = '$url'");
    return Future.value(result.isNotEmpty);
  }

  Future<int> deleteStorageUrl(int createAt) async {
    final db = await dbProvider.db;
    var result = await db
        .delete(storageTable, where: 'create_at = ?', whereArgs: [createAt]);
    return result;
  }

  Future<int> deleteAllStorageUrls() async {
    final db = await dbProvider.db;
    var result = await db.delete(storageTable);
    return result;
  }
}
