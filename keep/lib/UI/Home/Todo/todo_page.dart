import 'package:flutter/material.dart';
import 'package:keep/models/todo.dart';
import 'package:keep/bloc/todo_bloc.dart';
import 'package:keep/UI/Home/Todo/todo_editor.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:provider/provider.dart';

class TodoPage extends StatelessWidget {
  final TodoBloc todoBloc = TodoBloc();
  final int uid = UserProvider.getUserId();
  //Allows Todo card to be dismissable horizontally
  final DismissDirection _dismissDirection = DismissDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    debugPrint('load todo page....');
    return Provider(
        create: (context) => todoBloc,
        dispose: (context, bloc) => bloc.dispose(),
        child: Scaffold(
            resizeToAvoidBottomPadding: false,
            body: SafeArea(
                child: Container(
                    padding: const EdgeInsets.only(
                        left: 2.0, right: 2.0, bottom: 2.0),
                    child: Container(child: getTodosWidget()))),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Padding(
                padding: EdgeInsets.only(bottom: 25),
                child: FloatingActionButton(
                    elevation: 5.0,
                    onPressed: () async {
                      // 悬浮按钮添加todo项目
                      final res = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AddTodo(uid: uid);
                      }));
                      if (res != null && res) {
                        print("yes");
                        Future.delayed(Duration(milliseconds: 700),
                            () => todoBloc.getTodos());
                      }
                    },
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.add,
                      size: 32,
                      color: Colors.indigoAccent,
                    )))));
  }

  Widget getTodosWidget() {
    return StreamBuilder(
      stream: todoBloc.todos,
      builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
        return getTodoCardWidget(snapshot);
      },
    );
  }

  Widget getTodoCardWidget(AsyncSnapshot<List<Todo>> snapshot) {
    Widget page;
    if (snapshot.hasData)
      page = snapshot.data.length > 0
          ? buildTodoList(snapshot.data)
          : noTodoMessageWidget();
    else
      page = loadingData();
    return page;
  }

  Widget buildTodoList(data) {
    debugPrint('update the whole todo list .....');
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, itemPosition) {
          Todo todo = data[itemPosition];
          return Dismissible(
            key: new ObjectKey(todo),
            direction: _dismissDirection,
            background: Container(
              color: Colors.redAccent,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Deleting",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            onDismissed: (direction) => todoBloc
                .deleteTodoById(todo.id)
                .then((_) => todoBloc.getTodos()),
            child: Container(
                // padding: EdgeInsets.symmetric(vertical: 5),
                child: Stack(children: [
              Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey[200], width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  color: Colors.white,
                  child: SizedBox(
                      height: 90,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        onTap: () async {
                          final res = await Navigator.push(context,
                              new MaterialPageRoute(builder: (_) {
                            return AddTodo(uid: uid, todo: todo);
                          }));
                          if (res != null && res) {
                            Future.delayed(Duration(milliseconds: 700),
                                () => todoBloc.getTodos());
                            // todoBloc.getTodos();
                          }
                        },
                        leading: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            //Reverse the value
                            todo.isDone = !todo.isDone;
                            todoBloc.updateTodo(todo);
                          },
                          child: todo.isDone
                              ? Icon(
                                  Icons.done,
                                  size: 24.0,
                                  color: Colors.black,
                                )
                              : Icon(
                                  Icons.check_box_outline_blank,
                                  size: 24.0,
                                  color: Colors.black,
                                ),
                        ),
                        title: Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.w500,
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none),
                        ),
                      ))),
              Positioned(
                top: 0,
                right: 0,
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        padding: EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Text(todo.ddl == null ? "no ddl" : todo.ddl))),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        margin: EdgeInsets.only(left: 15, bottom: 10),
                        child: SizedBox(
                          height: 20,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: todo.tag.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.only(right: 5),
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    // color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    border: Border.all(
                                        color: Colors.grey.withGreen(164))),
                                child: Center(
                                    child: Text(todo.tag[index],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13.0))),
                              );
                            },
                          ),
                        ),
                      )))
            ])),
          );
        });
  }

  Widget loadingData() {
    //pull todos again
    // todoBloc.getTodos();
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text("Loading...",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget noTodoMessageWidget() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        "Start adding Todo...",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
    );
  }
}
