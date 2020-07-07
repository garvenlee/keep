import 'package:keep/data/dao/note_dao.dart';
import 'package:keep/models/note.dart';
// import 'package:keep/utils/event_util.dart';

class NoteRepository {
  final noteDao = NoteDao();

  Future getAllNotes({String whereString, List<String> query}) =>
      noteDao.getNotes(whereString: whereString, query: query);

  Future getNoteById(int createAt) => noteDao.getNoteById(createAt);

  Future<List<Note>> getNotSyncNotes() => noteDao.getNotSyncNotes();

  Future insertNote(Note note) => noteDao.createNote(note);

  int get getNum => noteDao.getNum;

  Future updateNote(Note note) => noteDao.updateNote(note);

  Future deleteNoteById(int id) => noteDao.deleteNote(id);

  //We are not going to use this in the demo
  Future deleteAllNotes() => noteDao.deleteAllNotes();

  Future deleteAllTrash() => noteDao.deleteAllTrash();

  Future checkNoteState(List<Note> serverNotes) =>
      noteDao.checkNoteState(serverNotes);
}
