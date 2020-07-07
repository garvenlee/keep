import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

final messageTable = 'Message';
final todoTable = 'Todo';
final noteTable = 'Note';
final storageTable = 'StorageUrl';
final roomTable = 'Room';
final roomClientTable = 'RoomClient';
final recentContactTable = 'RecentContact';
final recentGroupTable = 'RecentGroup';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  static final String columnCreateAt = "create_at";

  Future<Database> get db async {
    // print('get db======================================>');
    if (_db != null) return _db;
    // print('_db is null');
    _db = await initDb();
    return _db;
  }

  static closeDb() {
    _db.close();
    _db = null;
  }

  initDb() async {
    int userId = UserProvider.getUserId();
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "$userId.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    print("Created tables");
    Batch batch = db.batch();
    batch.execute("CREATE TABLE $messageTable ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "chat_type INTEGER,"
        "message_type TEXT,"
        "message_body TEXT,"
        "creator_id INTEGER,"
        "recipient_id INTEGER,"
        "recipient_group_id INTEGER,"
        "is_online INTEGER,"
        "is_read INTEGER,"
        "is_delete INTEGER,"
        "create_at INTEGER,"
        "expired_at INTEGER"
        ")");
    batch.execute("CREATE TABLE $todoTable ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "user_id INTEGER NOT NULL, "
        "todo_id INTEGER, "
        "hasupload INTEGER,"
        "tag TEXT,"
        "description TEXT,"
        "ddl TEXT,"
        "is_done INTEGER,"
        "created_at INTEGER, "
        "modified_at INTEGER"
        ")");
    batch.execute("CREATE TABLE $noteTable ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "user_id INTEGER NOT NULL, "
        "note_id INTEGER, "
        "title TEXT, "
        "content TEXT, "
        "tag TEXT, "
        "color TEXT, "
        "state INTEGER, "
        "created_at INTEGER, "
        "modified_at INTEGER, "
        "is_sync INTEGER"
        ")");
    batch.execute("CREATE TABLE $storageTable ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "url TEXT, "
        "title TEXT, "
        "avatar TEXT, "
        "tags TEXT, "
        "note TEXT, "
        "create_at INTEGER"
        ")");
    batch.execute("CREATE TABLE $roomTable ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "room_id INTEGER, "
        "room_name TEXT, "
        "room_number TEXT, "
        "room_size INTEGER, "
        "room_avatar TEXT, "
        "user_id INTEGER, "
        "username TEXT, "
        "email TEXT, "
        "user_avatar TEXT, "
        "create_at INTEGER"
        ")");
    batch.execute("CREATE TABLE $roomClientTable ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "room_id INTEGER, "
        "user_id INTEGER, "
        "username TEXT, "
        "email TEXT, "
        "user_avatar TEXT, "
        "join_at INTEGER"
        ")");
    batch.execute("CREATE TABLE $recentContactTable("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "user_one_id INTEGER,"
        //
        "user_two_id INTEGER,"
        "user_two_email TEXT,"
        "user_two_username TEXT,"
        "user_two_pickname TEXT,"
        "user_two_avatar TEXT,"
        //
        "last_seen_time INTEGER,"
        "is_friend INTEGER"
        ")");
    batch.execute("CREATE TABLE $recentGroupTable("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "group_id INTEGER,"
        "group_name TEXT,"
        "group_number TEXT,"
        "group_avatar TEXT,"
        "group_size INTEGER,"
        //
        "user_id INTEGER,"
        "username TEXT,"
        "email TEXT,"
        "user_avatar TEXT,"
        //
        "last_seen_time INTEGER,"
        "is_add_in INTEGER"
        ")");
    await batch.commit();
  }
}
