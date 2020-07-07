import 'package:keep/models/todo.dart';
import 'package:keep/data/repository/todo_repository.dart';
// import 'package:rxdart/rxdart.dart';
import 'dart:async';

class TodoBloc {
  //Get instance of the Repository
  final _todoRepository = TodoRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  // var _subject = BehaviorSubject<List<Todo>>();
  final _todoController = StreamController<List<Todo>>.broadcast();

  Stream<List<Todo>> get todos => _todoController.stream;
  // get total => todos.length;
  // get todos => _subject.stream;

  TodoBloc() {
    getTodos();
  }

  getTodos({String query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _todoController.sink.add(await _todoRepository.getAllTodos(query: query));
  }

  getTodoById(int createAt) async =>
      await _todoRepository.getTodoById(createAt);

  addTodo(Todo todo) async {
    await _todoRepository.insertTodo(todo);
    getTodos();
  }

  updateTodo(Todo todo) async {
    await _todoRepository.updateTodo(todo);
    getTodos();
  }

  deleteTodoById(int id) async {
    _todoRepository.deleteTodoById(id);
    getTodos();
  }

  dispose() {
    _todoController.close();
  }
}
