import 'package:keep/models/todo.dart';
import 'package:keep/service/rest_ds.dart';

abstract class TodoSyncContact {
  void onSyncSuccess(int todoId);
  void onSyncError(String errorText);
}

class TodoSyncPresenter {
  TodoSyncContact _view;
  RestDatasource _api = new RestDatasource();
  TodoSyncPresenter(this._view);

  syncTodo(Todo todo, bool isNewItem) {
    print(todo);
    _api.syncTodo(todo, isNewItem).then((int todoId) {
      print('get note id from server is $todoId');
      _view.onSyncSuccess(todoId);
    }).catchError((Object error) {
      _view.onSyncError(error.toString());
    });
  }
}
