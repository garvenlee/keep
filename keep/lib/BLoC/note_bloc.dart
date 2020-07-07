// import 'package:keep/service/rest_ds.dart';
import 'package:keep/models/note.dart';
import 'package:keep/data/repository/note_repository.dart';
import 'dart:async';

class NoteBloc {
  //Get instance of the Repository
  final _noteRepository = NoteRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers

  String whereString;
  List<String> query;
  final _noteController = StreamController<List<Note>>.broadcast();

  get notes => _noteController.stream;

  NoteBloc({String whereString, List<String> query}) {
    whereString = whereString;
    query = query;
    getNotes(whereString: whereString, query: query);
  }

  getNotes({String whereString, List<String> query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _noteController.sink.add(await _noteRepository.getAllNotes(
        whereString: whereString, query: query));
  }

  int get getNum => _noteRepository.getNum;

  getNoteById(int createAt) async =>
      await _noteRepository.getNoteById(createAt);

  Future<List<Note>> getNotSyncNotes() async =>
      await _noteRepository.getNotSyncNotes();

  addNote(Note note) async {
    await _noteRepository.insertNote(note);
    getNotes(whereString: whereString, query: query);
  }

  updateNote(Note note) async {
    await _noteRepository.updateNote(note);
    getNotes(whereString: whereString, query: query);
  }

  deleteNoteById(int id) async {
    _noteRepository.deleteNoteById(id);
    getNotes(whereString: whereString, query: query);
  }

  deleteAllTrash() async {
    _noteRepository.deleteAllTrash();
    getNotes(whereString: whereString, query: query);
  }

  checkNoteState(List<Note> notes) async {
    _noteRepository.checkNoteState(notes);
    getNotes(whereString: whereString, query: query);
  }

  dispose() {
    _noteController.close();
  }
}
