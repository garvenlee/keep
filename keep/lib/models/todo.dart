import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:keep/BLoC/todo_bloc.dart';

class Todo with ChangeNotifier {
  int id;
  final int uid;
  int todoId;
  bool hasupload; //是否已经上传到服务器
  List<String> tag;
  String description;
  String ddl;
  bool isDone; // 标志完成与否
  final int createdAt;
  int modifiedAt;

  Todo(
      {this.id,
      this.uid,
      this.todoId,
      this.ddl,
      this.description,
      this.tag,
      bool hasupload,
      bool isDone,
      int createdAt,
      int modifiedAt})
      : this.hasupload = hasupload ?? true,
        this.isDone = isDone ?? false,
        this.createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        this.modifiedAt = modifiedAt ?? DateTime.now().millisecondsSinceEpoch;

  Todo copy() => Todo(
      id: id,
      uid: uid,
      todoId: todoId,
      hasupload: hasupload,
      tag: tag,
      description: description,
      ddl: ddl,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      isDone: isDone);

  set deadline(String value) {
    this.ddl = value;
    notifyListeners();
  }

  factory Todo.fromDatabaseJson(Map<String, dynamic> data) => Todo(
      id: data['id'],
      uid: data['user_id'],
      todoId: data['todo_id'],
      hasupload: data['hasupload'] == 1,
      description: data['description'],
      tag: data['tag'].split(' '),
      ddl: data['ddl'],
      createdAt: data['created_at'],
      modifiedAt: data['modified_at'],
      isDone: data['is_done'] == 1);

  Map<String, dynamic> toDatabaseJson() => {
        "user_id": this.uid,
        "todo_id": this.todoId,
        "hasupload": this.hasupload ?? false ? 1 : 0,
        "tag": this.tag.join(' '),
        "description": this.description,
        "ddl": this.ddl,
        "created_at": this.createdAt,
        "modified_at": this.modifiedAt,
        "is_done": this.isDone ?? false ? 1 : 0,
      };

  static Todo fromMap(Map<String, dynamic> data) => Todo(
        id: data['id'],
        uid: data['user_id'],
        todoId: data['todo_id'],
        hasupload: data['hasupload'] == 1,
        description: data['discription'],
        ddl: data['ddl'],
        tag: data['tag'] ?? '',
        createdAt: data['created_at'],
        modifiedAt: data['modified_at'],
        isDone: data['is_done'] == 1,
      );

  @override
  String toString() {
    return '{ ${this.id} ${this.todoId} ${this.description} ${this.ddl} ${this.isDone} ${this.tag} }';
  }

  Map toJson() => {
        'todo_id': todoId,
        'user_id': uid,
        'description': description,
        'tag': tag.join(' '),
        'ddl': ddl,
        'is_done': isDone ? 1 : 0,
        'hasupload': hasupload ? 1 : 0,
        'created_at': createdAt,
        'modified_at': modifiedAt,
      };

  static List<Todo> fromQuery(decodedJson) => decodedJson != null
      ? (decodedJson.map((obj) => Todo.fromMap(obj)).toList().cast<Todo>())
      : [];

  Future<dynamic> saveToLocalDb() async {
    final bloc = TodoBloc();
    id == null ? bloc.addTodo(this) : bloc.updateTodo(this);
  }

  @override
  bool operator ==(other) =>
      other is Todo &&
      (other.id ?? '') == (id ?? '') &&
      (other.description ?? '') == (description ?? '') &&
      (other.ddl ?? '') == (ddl ?? '') &&
      (other.tag ?? '') == (tag ?? '');

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;

  @override
  void dispose() {
    super.dispose();
  }
}
