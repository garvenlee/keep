import 'package:flutter/material.dart';
import 'package:keep/models/todo.dart';

class TodosProvider with ChangeNotifier {
  final List<Todo> _todos;
  TodosProvider(this._todos);

  int get total => _todos != null ? _todos.length: 0;
  List<Todo> get todos => _todos;

  addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class TodosProviderManager {
  static final TodosProviderManager _instance = new TodosProviderManager.internal();
  TodosProviderManager.internal();
  factory TodosProviderManager() => _instance;

  static TodosProvider _todosProvider;

  TodosProvider get provider {
    // print('get db======================================>');
    if (_todosProvider != null) return _todosProvider;
    // print('_db is null');
    _todosProvider = TodosProvider([]);
    return _todosProvider;
  }

  set provdier(TodosProvider provider) {
    _todosProvider = provider;
  }
}