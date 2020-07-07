import 'package:keep/models/group.dart';
import 'package:keep/models/group_client.dart';

class GroupSource {
  final Group group;
  final List<GroupClient> clients;
  GroupSource({this.group, this.clients});

  static GroupSource fromMap(Map map1, List<Map> map2) {
    List<GroupClient> clients = [];
    map2.forEach((member) {
      clients.add(GroupClient.fromMap(member));
    });
    return new GroupSource(group: Group.fromMap(map1), clients: clients);
  }

  Map<String, dynamic> encodeStr() {
    // print('toJson');
    return {
      'group': group.toJson(),
      'clients': clients.map((e) => e.toJson()).toList()
    };
  }

  static GroupSource decodeStr(Map jsonData) {
    Group group = Group.fromJson(jsonData['group']);
    List<GroupClient> clients = jsonData['clients']
        .map((e) => GroupClient.fromJson(e))
        .cast<GroupClient>()
        .toList();
    return GroupSource(group: group, clients: clients);
  }
}
