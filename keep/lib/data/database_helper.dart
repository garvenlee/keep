import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static int _userId;
  static Database _db;

  static final String columnCreateAt = "create_at";

  Future<Database> get db async {
    print('get db======================================>');
    print(UserProvider.getUserId());
    print(_userId);
    if (_db != null && UserProvider.getUserId() == _userId) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    _userId = UserProvider.getUserId();
    String userId = _userId.toString();
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "$userId.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    print("Created tables");
    Batch batch = db.batch();
    batch.execute("CREATE TABLE Message("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        // "msg_id INTEGER,"
        "chat_type INTEGER,"
        "message_type TEXT,"
        "message_body TEXT,"
        "creator_id INTEGER,"
        "recipient_id INTEGER,"
        "recipient_group_id INTEGER,"
        "is_read INTEGER,"
        "create_at INTEGER,"
        "expired_at INTEGER"
        ")");
    batch.execute("CREATE TABLE RecentContacts("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "user_one_id INTEGER,"
        "user_two_id INTEGER"
        ")");
    batch.execute("CREATE TABLE RecentGroups("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "user_id INTEGER,"
        "group_id INTEGER"
        ")");
    await batch.commit();
  }
}
