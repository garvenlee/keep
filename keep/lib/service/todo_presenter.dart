import 'package:keep/models/todo.dart';
// import 'package:keep/data/sputil.dart';
import 'package:keep/service/rest_ds.dart';
import 'package:keep/BLoC/todo_bloc.dart';
// import 'package:keep/data/provider/user_provider.dart';

class TodoPresenter {
  static final RestDatasource _api = new RestDatasource();
  static getCollections(int userId) async {
    final todoBloc = TodoBloc();
    // 往数据库写数据时应该判断数据库有没有这个数据
    _api.getTodos(userId).then((List<Todo> data) {
      print('length : ${data.length}');
      data.forEach((todo) {
        todoBloc.getTodoById(todo.createdAt).then((res) {
          if (res == null)
            todoBloc.addTodo(todo);
          else
            print('do not have to do anything');
        });
      });
      print('get Todos done.');
    }).catchError((Object error) {
      print('still have not Todos yet.');
      print(error.toString());
    });
  }
}
