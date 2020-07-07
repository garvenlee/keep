import 'dart:async';
import 'package:keep/data/database_helper.dart';
import 'package:keep/models/note.dart';
import 'package:keep/data/sputil.dart';

class NoteDao {
  final dbProvider = DatabaseHelper();
  static int noteNum = SpUtil.getInt('noteNum', defValue: 0);

  int get getNum => noteNum;

  //Adds new note records
  Future<int> createNote(Note note) async {
    final db = await dbProvider.db;
    var result = db.insert(noteTable, note.toDatabaseJson());
    noteNum += 1;
    SpUtil.putInt('noteNum', noteNum);
    return result;
  }

  //Get All Todo items
  //Searches if query string was passed
  Future<List<Note>> getNotes(
      {List<String> columns, String whereString, List<String> query}) async {
    final db = await dbProvider.db;
    // print(whereString);
    List<Map<String, dynamic>> result;
    if (query != null && query.length > 0) {
      result = await db.query(noteTable,
          columns: columns,
          where: whereString,
          whereArgs: query,
          orderBy: 'state DESC');
    } else {
      result = await db.query(noteTable, columns: columns);
    }
    // print(result);
    List<Note> notes = result.isNotEmpty
        ? result.map((item) => Note.fromDatabaseJson(item)).toList()
        : [];
    notes.sort((left, right) => left.createdAt > right.createdAt ? 1 : 0);
    // notes.map((e) => print(e.state.index));
    return notes;
  }

  Future<List<Note>> getNotSyncNotes() async {
    List<Map<String, dynamic>> result;
    final db = await dbProvider.db;
    result = await db.rawQuery('SELECT * FROM $noteTable WHERE is_sync = 0');
    return result.isNotEmpty ? Note.fromQuery(result) : [];
  }

  Future<Note> getNoteById(int createAt) async {
    final db = await dbProvider.db;
    var result = await db
        .rawQuery('SELECT * FROM $noteTable WHERE created_at = $createAt');
    return result.isNotEmpty ? Note.fromMap(result[0]) : null;
  }

  Future<Note> getNoteByNoteId(int id) async {
    final db = await dbProvider.db;
    var result = await db.rawQuery('SELECT * FROM $noteTable WHERE id = $id');
    return Note.fromMap(result[0]);
  }

  //Update Todo record
  Future<int> updateNote(Note note) async {
    final db = await dbProvider.db;

    var result = await db.update(noteTable, note.toDatabaseJson(),
        where: "created_at = ?", whereArgs: [note.createdAt]);

    return result;
  }

  //Delete Todo records
  Future<int> deleteNote(int id) async {
    final db = await dbProvider.db;
    var result = await db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //We are not going to use this in the demo
  Future deleteAllNotes() async {
    final db = await dbProvider.db;
    var result = await db.delete(
      noteTable,
    );
    return result;
  }

  Future deleteAllTrash() async {
    final db = await dbProvider.db;
    var result = await db.rawQuery('DELETE FROM $noteTable WHERE state = 3');
    return result;
  }

  Future handleSyncStatus(List<int> errNotesId) async {
    final db = await dbProvider.db;
    print('handle sync==================>');
    return await db
        .rawQuery('UPDATE $noteTable SET is_sync = 1 WHERE is_sync = 0')
        .then((_) {
      errNotesId.forEach((noteId) async {
        await db.rawQuery(
            'UPDATE $noteTable SET is_sync = 0 WHERE note_id = $noteId');
      });
    });
  }

  Future checkNoteState(List<Note> serverNotes) async {
    serverNotes.forEach((sNote) {
      // print(sNote.toDatabaseJson());
      getNoteById(sNote.createdAt).then((localNote) {
        // print(localNote.title);
        if (localNote == null) {
          print(sNote);
          createNote(sNote);
        } else if (localNote.modifiedAt < sNote.modifiedAt) {
          print('need to update');
          updateNote(sNote);
        }
      });
    });
    return Future.value(true);
  }
}
