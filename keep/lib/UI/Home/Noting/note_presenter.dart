import 'package:keep/service/rest_ds.dart';
import 'package:keep/models/note.dart';

abstract class NoteScratchContract {
  void onScratchSuccess(List<Note> notes);
  void onScratchError(String errorTxt);
}

abstract class NoteSyncContact {
  void onSyncSuccess(int noteId);
  void onSyncError(String errorText);
}

class NoteScratchPresenter {
  NoteScratchContract _view;
  // RestDatasource 用于向服务器端请求数据
  RestDatasource api = new RestDatasource();
  NoteScratchPresenter(this._view);

  // 发起请求并用于捕捉异常
  syncNotes(int userId, List<Note> notes) {
    api.syncNotes(userId, notes).then((List<Note> notes) {
      print('need to compare notes');
      print(notes.length);
      _view.onScratchSuccess(notes);
    }).catchError((Object error) {
      _view.onScratchError(error.toString());
    });
  }
}

class NoteSyncPresenter {
  NoteSyncContact _view;
  RestDatasource api = new RestDatasource();
  NoteSyncPresenter(this._view);

  syncNote(Note note, bool newItem) {
    print('note state value is ${note.stateValue}');
    print('note id is ${note.noteId}');
    print('note synced is new or not: $newItem');
    api.syncNote(note, newItem).then((int noteId) {
      print('get note id from server is $noteId');
      _view.onSyncSuccess(noteId);
    }).catchError((Object error) {
      _view.onSyncError(error.toString());
    });
  }
}
