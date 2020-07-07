import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'todo_tag.dart';
import 'package:keep/bloc/todo_bloc.dart';
import 'package:keep/models/todo.dart';
import 'package:keep/utils/tools_function.dart' show showHintText;
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'todo_presenter.dart';

class AddTodo extends StatefulWidget {
  final Todo todo;
  final int uid;
  AddTodo({Key key, this.todo, this.uid}) : super(key: key);

  @override
  _AddTodoState createState() => _AddTodoState(todo, uid);
}

class _AddTodoState extends State<AddTodo> implements TodoSyncContact {
  final TodoBloc todoBloc = TodoBloc();
  final Todo _todo;
  final Todo _originalTodo;
  final _todoDescriptionFormController;

  _AddTodoState(Todo todo, int uid)
      : this._todo = todo ?? Todo(tag: [], uid: uid, ddl: ''),
        this._originalTodo = todo?.copy(),
        this._todoDescriptionFormController =
            TextEditingController(text: todo?.description) {
    _presenter = new TodoSyncPresenter(this);
  }

  BuildContext _ctx;
  TodoSyncPresenter _presenter;
  var connectionStatus;

  Future<bool> _onPop() {
    print('111111111111退出');
    return Future.value(true);
  }

  void onSyncSuccess(int todoId) {
    debugPrint('sync to node server successfully.');
    debugPrint('get note id is $todoId');
    _todo
      ..todoId = todoId
      ..hasupload = true
      ..saveToLocalDb();
  }

  void onSyncError(String errorText) {
    debugPrint(errorText);
    _todo
      ..hasupload = false
      ..saveToLocalDb();
  }

  bool get _isDirty => _todo != _originalTodo;

  @override
  void initState() {
    super.initState();
    _todoDescriptionFormController.addListener(
        () => _todo.description = _todoDescriptionFormController.text);
    //初始化状态
    print("initState,###################");
  }

  @override
  void dispose() {
    todoBloc.dispose();
    _todoDescriptionFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    return Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Colors.white,
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                elevation: 0,
              ),
          scaffoldBackgroundColor: Colors.white,
          bottomAppBarColor: Colors.white,
        ),
        child: ChangeNotifierProvider<Todo>.value(
            value: _todo,
            builder: (context, child) => Scaffold(
                appBar: AppBar(
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                body: WillPopScope(
                    onWillPop: () => _onPop(),
                    child: Container(
                        padding: EdgeInsets.fromLTRB(32.0, 18, 32.0, 18),
                        child: SingleChildScrollView(
                          child: ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              SizedBox(
                                  child: buildTodoSection(),
                                  height: ScreenUtil.screenHeight * 0.21),
                              SizedBox(
                                  child: buildTagSection(),
                                  height: ScreenUtil.screenHeight * 0.35),
                              SizedBox(
                                  height: ScreenUtil.screenHeight * 0.00008),
                              SizedBox(
                                  child: buildTimeSection(),
                                  height: ScreenUtil.screenHeight * 0.15),
                              SizedBox(height: ScreenUtil.screenHeight * 0.02),
                              SizedBox(
                                  child: buildActionButton(connectionStatus),
                                  height: ScreenUtil.screenHeight * 0.12)
                            ],
                          ),
                        ))))));
  }

  Widget buildTodoSection() {
    return Container(
        height: 148,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildtTodoHint(),
          inputTextField(),
        ]));
  }

  Widget buildtTodoHint() {
    return Container(
        height: 20.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "New Todo",
          style: TextStyle(
              color: Colors.black87, fontFamily: "Raleway", fontSize: 18.0),
        ));
  }

  Widget inputTextField() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        height: 112,
        child: new TextFormField(
            controller: _todoDescriptionFormController,
            maxLines: 3,
            decoration: InputDecoration.collapsed(hintText: 'I have to...')));
  }

  Widget buildTagSection() {
    return Consumer<Todo>(
        builder: (_, todo, child) => Container(
            height: 180,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [child, TodoTagField(todo: todo)])),
        child: buildTagHint());
  }

  Widget buildTagHint() {
    return Container(
        height: 20.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          "Add tags ",
          style: TextStyle(
              color: Colors.black87, fontFamily: "Raleway", fontSize: 18.0),
        ));
  }

  Widget buildAddTimeHint(Todo todo) {
    return Container(
        color: Colors.white,
        height: 80,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          FlatButton(
              padding: EdgeInsets.only(left: 0),
              onPressed: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(1900, 3, 5),
                    maxTime: DateTime(2050, 6, 7), onChanged: (date) {
                  print('change $date');
                }, onConfirm: (date) {
                  String tmp = date.toString();
                  List m = tmp.split(' ');
                  List n = m[1].split(':');
                  todo.deadline = m[0].toString() +
                      ' ' +
                      n[0].toString() +
                      ':' +
                      n[1].toString();
                  print('##################confirm ${_todo.ddl}');
                }, currentTime: DateTime.now(), locale: LocaleType.zh);
              },
              child: Text(
                ' Set the deadline',
                style: TextStyle(color: Colors.blue[300], fontSize: 18.0),
              ))
        ]));
  }

  Widget buildTimeDisplaySection(Todo todo) {
    return Container(
        height: 20,
        // padding: EdgeInsets.only(left: 16),
        // alignment: Alignment.center,
        child: Text(
          todo.ddl.isEmpty ? '' : 'deadline: ${_todo.ddl}',
          style: TextStyle(fontSize: 16.0, color: Colors.black54),
        ));
  }

  Widget buildTimeSection() {
    return Consumer<Todo>(
        builder: (_, todo, __) => Container(
            height: 120,
            child: Column(
              children: [buildAddTimeHint(todo), buildTimeDisplaySection(todo)],
            )));
  }

  Widget buildActionButton(ConnectivityStatus connectionStatus) {
    return Container(
        height: 54,
        // color: Colors.pinkAccent[100],
        // 返回按钮和保存按钮
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // 放弃本次编辑，返回todo界面
              new SizedBox(
                  width: 140.0,
                  child: FlatButton(
                    color: Colors.lightBlue,
                    // highlightColor: Colors.lightBlue[200],
                    colorBrightness: Brightness.dark,
                    splashColor: Colors.grey,
                    child: Text("Back"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () {
                      // Navigator.pop(_ctx);
                      Navigator.pop(_ctx, true);
                    },
                  )),

              // 保存编辑的todo
              new SizedBox(
                  width: 140.0,
                  child: FlatButton(
                    color: Colors.lightBlue,
                    // highlightColor: Colors.lightBlue[200],
                    colorBrightness: Brightness.dark,
                    splashColor: Colors.grey,
                    child: Text("Done"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () async {
                      print('按下###############');
                      if (_isDirty &&
                          (_todo.id != null || _todo.description.isNotEmpty)) {
                        _todo.modifiedAt =
                            DateTime.now().millisecondsSinceEpoch;
                        if (connectionStatus == ConnectivityStatus.Available) {
                          // 网络已连接, 创建新todo和修改 旧todo需要上传，
                          print('sending todo to the backend!!!!!!!!!!!');
                          // print(_todo.hasupload);
                          _presenter.syncTodo(_todo, _todo.id == null);
                        } else {
                          _todo
                            ..hasupload = false
                            ..saveToLocalDb();
                        }
                        debugPrint(
                            'need to insert new item: ${_todo.id == null || _isDirty}');
                        Navigator.pop(_ctx, _todo.id == null || _isDirty);
                      } else
                        showHintText("Please add something.");
                    },
                  ))
            ]));
  }

// todo添加tag的按钮
  Widget buildAddButton() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Colors.pinkAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.add,
            color: Colors.white,
            size: 15.0,
          ),
          Text(
            "Add New Tag",
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
