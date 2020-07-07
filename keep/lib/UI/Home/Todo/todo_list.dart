import 'package:flutter/material.dart';
import 'package:keep/models/todo.dart';
import 'package:provider/provider.dart';
import 'package:keep/data/provider/todo_provider.dart';

class TodoList extends StatelessWidget {
  const TodoList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<List<Todo>>(context);
    debugPrint(todos?.length.toString());
    return ChangeNotifierProvider<TodosProvider>(
              create: (context) => TodosProvider(todos??[]),
              child: Selector<TodosProvider, TodosProvider>(
                shouldRebuild: (pre, next) => pre.total != next.total,
                selector: (context, provider) => provider,
                builder: (context, provider, child) => ListView.builder(
                    itemCount: provider.total,
                    itemBuilder: (context, idnex) =>
                        Selector<TodosProvider, Todo>(
                          selector: (context, provider) =>
                              provider.todos[idnex],
                          builder: (context, data, child) => Container(
                              child: Center(
                                  child: Text('${data?.description}',
                                      style: TextStyle(fontSize: 22.0)))),
                        )),
              ),
            );
  }
}
