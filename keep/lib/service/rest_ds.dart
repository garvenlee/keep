import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:keep/data/dao/note_dao.dart';
import 'package:keep/models/group.dart';
import 'package:keep/models/group_client.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/utils/network_util.dart';
import 'package:keep/models/user.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/models/group_source.dart';
import 'package:keep/models/note.dart';
import 'package:keep/models/todo.dart';
import 'package:keep/data/sputil.dart';
import 'package:keep/settings/config.dart';
import 'package:keep/data/provider/user_provider.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  // static final baseURL = httpUrl;
  static final baseURL = "http://$baseIP:$port/";
  static final userNamespace = 'user/';
  static final imageNamespace = 'image/';
  static final chatNamespace = 'chat/';
  static final addContactNamespace = 'addContacts/';
  static final noteNamespace = 'note/';
  static final todoNamespace = 'todo/';

  static final loginURL = baseURL + userNamespace + "login";
  static final registerURL = baseURL + userNamespace + "register";
  static final checkURL = baseURL + userNamespace + "check";
  static final resetURL = baseURL + userNamespace + "reset";
  static final userPicURL = baseURL + imageNamespace + 'upload';
  static final makeFriendURL = baseURL + addContactNamespace;

  // static final _apiKey = "somerandomkey";

  static final chatLoginURL = baseURL + chatNamespace;
  static final getOneGroupURL = baseURL + chatNamespace + 'group/get';
  // Map<String, SocketIO> sockets = {};

  static final syncTodoURL = baseURL + todoNamespace + 'sync';

  static final syncNoteURL = baseURL + noteNamespace + 'sync';
  static final syncNotesURL = baseURL + noteNamespace + 'syncs';

  Future<User> login(String email, String password) {
    print('login......');
    // print(email + ' ' + password);
    return _netUtil
        .post(loginURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json"
            },
            body: json.encode({
              "email": email,
              "password": password,
            }),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      // save token to localstorage
      SpUtil.putString('token', res['token']);
      return new User.map(res["user"]);
    });
  }

  Future<String> register(
      String username, String email, String password, String phone) {
    return _netUtil
        .post(registerURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: json.encode({
              "username": username,
              "email": email,
              "password": password,
              "phone": phone
            }),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return res['hint_msg'];
    });
  }

  Future<String> reset(String email, String password) {
    return _netUtil
        .post(resetURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: json.encode({"email": email, "password": password}),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return res['username'];
    });
  }

  Future<String> check(String email) {
    return _netUtil
        .post(checkURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
            },
            body: json.encode({
              "email": email,
            }),
            encoding: Utf8Codec())
        .then((dynamic res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return res['verification_code'];
    });
  }

  Future<GroupSource> getGroupByNumber(String roomNumber) {
    return _netUtil
        .post(getOneGroupURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body: json.encode(
                {"roomNumber": roomNumber, "userId": UserProvider.getUserId()}),
            encoding: Utf8Codec())
        .then((res) {
      // print(res);
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      Group group = Group.fromMap(res['data']['room']);
      List<GroupClient> clients = [];
      res['data']['members'].forEach((member) {
        member['room_id'] = res['data']['room']['room_id'];
        if (member['client_flag'] == 1) {
          member['username'] = UserProvider().username;
          member['email'] = UserProvider().email;
          member['user_avatar'] = UserProvider().avatar;
        }
        clients.add(GroupClient.fromMap(member));
      });
      return GroupSource(group: group, clients: clients);
    });
  }

  Future<List<GroupSource>> getGroups(int userId) {
    String getGroupsURL =
        baseURL + chatNamespace + 'groups/get/' + userId.toString();
    return _netUtil.get(getGroupsURL, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "token": SpUtil.getString('token') ?? 'null'
    }).then((res) {
      // print('group data scratch ================>');
      // print(res['rooms']["1"]['members']);

      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      // print("clients number is ${res['rooms']['11']['members'].length}");
      List<GroupSource> groupSource = [];
      List<String> keys = res['rooms'].keys.toList();
      // print('group keys ====================>');
      // print(keys);
      // print(keys[0].runtimeType);
      keys.forEach((key) {
        // String idKey = key.toString();
        String username;
        String userAvatar;
        String email;
        if (res['rooms'][key]['room_holder'] == 1) {
          username = UserProvider().username;
          email = UserProvider().email;
          userAvatar = UserProvider().avatar;
        } else {
          username = res['rooms'][key]['username'];
          email = res['rooms'][key]['email'];
          userAvatar = res['rooms'][key]['user_avatar'];
        }
        // print(key.runtimeType);
        Map map1 = {
          'room_id': int.parse(key),
          'room_name': res['rooms'][key]['room_name'],
          'room_number': res['rooms'][key]['room_number'],
          'room_size': res['rooms'][key]['room_size'],
          'room_avatar': res['rooms'][key]['room_avatar'],
          'user_id': res['rooms'][key]['user_id'],
          'username': username,
          'email': email,
          'avatar': userAvatar,
          'create_at': res['rooms'][key]['create_at']
        };
        List<Map> map2 = [];
        // print(res['rooms'].keys.toList()[0].runtimeType);
        // print(res['rooms'][key]['members']);
        res['rooms'][key]['members'].forEach((member) {
          // print('member=======================>');
          // print(member);
          String username;
          String userAvatar;
          String email;
          if (member['client_flag'] == 1) {
            username = UserProvider().username;
            email = UserProvider().email;
            userAvatar = UserProvider().avatar;
          } else {
            username = member['username'];
            email = member['email'];
            userAvatar = member['user_avatar'];
          }
          map2.add({
            'room_id': int.parse(key),
            'user_id': member['user_id'],
            'username': username,
            'email': email,
            'user_avatar': userAvatar,
            'join_at': member['join_at']
          });
        });
        groupSource.add(GroupSource.fromMap(map1, map2));
      });
      return groupSource;
    });
  }

  Future<List<Friend>> getFriends(int userId) {
    String getFriendsURL =
        baseURL + chatNamespace + 'friends/get/' + userId.toString();
    // print(getFriendsURL);
    return _netUtil.get(
      getFriendsURL,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "token": SpUtil.getString('token') ?? 'null'
      },
    ).then((res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      // print(res['error']);
      return Friend.allFromMapList(res['friends']);
    });
  }

  Future<List<UserMessage>> getMessages(int userId) {
    String getMessagesURL =
        baseURL + chatNamespace + 'messages/get/' + userId.toString();
    return _netUtil.get(getMessagesURL, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "token": SpUtil.getString('token') ?? 'null'
    }).then((res) {
      if (res['error']) throw new Exception(res['error_msg']);
      return UserMessage.allFromMapList(res['messages']);
    });
  }

  Future<List<Note>> getNotes(int userId) {
    String getNotesURL = baseURL + noteNamespace + 'get/' + userId.toString();
    // print(getNotesURL);
    return _netUtil.get(
      getNotesURL,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "token": SpUtil.getString('token') ?? 'null'
      },
    ).then((res) {
      // print(res);
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      // print(res['error']);
      return Note.fromQuery(res['notes']);
    });
  }

  Future<List<Note>> syncNotes(int uid, List<Note> notes) {
    print('sync not url: $syncNotesURL');
    print(notes.length);
    return _netUtil
        .post(syncNotesURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body: json.encode({'uid': uid, "offline_notes": notes}),
            encoding: Utf8Codec())
        .then((res) {
      if (res['error']) throw Exception(res['error_msg']);
      List<int> errNotes = res['data']['err_notes'].cast<int>();
      NoteDao dao = new NoteDao();
      dao.handleSyncStatus(errNotes);
      print(res['data']);
      return res['data']['res_notes'].length == 0
          ? []
          : Note.fromQuery(res['data']['res_notes']);
    });
  }

  Future<int> syncNote(Note note, bool newItem) {
    return _netUtil
        .post(syncNoteURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body: json.encode({"note": note, 'is_new_one': newItem}),
            encoding: Utf8Codec())
        .then((res) {
      if (res['error']) throw new Exception(res['error_msg']);
      return res['note_id'];
    });
  }

  Future<int> syncTodo(Todo todo, bool isNewItem) {
    print(todo.toJson());
    print(isNewItem);
    return _netUtil
        .post(syncTodoURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body: json.encode({"todo": todo, "is_new_one": isNewItem}),
            encoding: Utf8Codec())
        .then((res) {
      if (res['error']) throw new Exception(res['error_msg']);
      return res['todo_id'];
    });
  }

  Future<String> upload(File file, int userId) {
    String base64Image = base64Encode(file.readAsBytesSync());
    var nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
    // print(userPicURL);
    return _netUtil
        .post(userPicURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body: json.encode({
              "imageData": base64Image,
              "userId": userId,
              "timestamp": nowTimeStamp,
            }),
            encoding: Utf8Codec())
        .then((res) {
      // print(res['error']);
      if (res["error"]) {
        // print('throw error');
        throw new Exception(res["error_msg"]);
      }
      // print('no error.....');
      return res['hint_msg'];
    });
  }

  Future getUrlContent(String url,
      {Map<String, String> headers, bool isJson = false}) async {
    // print('processing..............');
    return _netUtil.get(url, headers: headers, isJson: isJson).then((res) {
      return res;
    });
  }

  //////////////////////////////////////////////

  Future<List<Todo>> getTodos(int userId) {
    String getTodosURL = baseURL + todoNamespace + 'get/' + userId.toString();
    print(getTodosURL);
    return _netUtil.get(
      getTodosURL,
      headers: {
        "content-type": "application/json",
        "accept": "application/json",
        "token": SpUtil.getString('token') ?? 'null'
      },
    ).then((res) {
      // print(res);
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      // print(res['error']);
      return Todo.fromQuery(res['todos']);
    });
  }

  Future<bool> createTodo(Todo todo, int userId, int todoId) async {
    String newTodoURL = baseURL + todoNamespace + 'create';
    print(newTodoURL);
    // print('todoId: $todoId');
    return _netUtil
        .post(newTodoURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body:
                json.encode({"todo": todo, "userId": userId, "todoId": todoId}),
            encoding: Utf8Codec())
        .then((res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return !res['error'];
    });
  }

  Future updateTodo(Todo todo, int userId, int todoId) async {
    String updateTodoURL = baseURL + todoNamespace + 'update';
    print(updateTodoURL);
    // print('todoId: $todoId');
    return _netUtil
        .post(updateTodoURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body:
                json.encode({"todo": todo, "userId": userId, "todoId": todoId}),
            encoding: Utf8Codec())
        .then((res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return !res['error'];
    });
  }

  Future checkTodoState({List<Todo> todos, int uid}) {
    String checkTodoStateURL = baseURL + todoNamespace + 'checkAll';
    return _netUtil
        .post(checkTodoStateURL,
            headers: {
              "content-type": "application/json",
              "accept": "application/json",
              "token": SpUtil.getString('token') ?? 'null'
            },
            body: json.encode({"todos": todos, "userId": uid}),
            encoding: Utf8Codec())
        .then((res) {
      if (res["error"]) {
        throw new Exception(res["error_msg"]);
      }
      return !res['error'];
    });
  }

//////////////////////////////////////////////
}
