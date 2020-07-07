import 'package:keep/models/note.dart';
// import 'package:keep/data/sputil.dart';
import 'package:keep/service/rest_ds.dart';
import 'package:keep/data/repository/note_repository.dart';
// import 'package:keep/BLoC/note_bloc.dart';
// import 'package:keep/data/provider/user_provider.dart';

class NotePresenter {
  static final RestDatasource _api = new RestDatasource();
  static getCollections(int userId) async {
    final noteRepo = NoteRepository();
    // 往数据库写数据时应该判断数据库有没有这个数据
    _api.getNotes(userId).then((List<Note> data) {
      print('length : ${data.length}');
      data.forEach((note) {
        noteRepo.getNoteById(note.createdAt).then((res) {
          if (res == null)
            noteRepo.insertNote(note);
          else if (res.modifiedAt != note.modifiedAt) {
            noteRepo.updateNote(note);
          } else
            print('do not have to do anything');
        });
      });
      print('get Notes done.');
    }).catchError((Object error) {
      print('still have not Notes yet.');
      print(error.toString());
    });
  }
}
