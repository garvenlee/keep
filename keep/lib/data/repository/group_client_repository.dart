import 'package:keep/data/dao/group_client.dart';
import 'package:keep/models/group_client.dart';
// import 'package:keep/utils/event_util.dart';

class GroupClientRepository {
  final groupClientDao = GroupClientDao();

  Future<List<GroupClient>> getAllGroupClients({String whereString, List<String> query}) =>
      groupClientDao.getGroupClients(whereString: whereString, query: query);
  
  Future newMember(GroupClient client) => groupClientDao.createGroupClient(client);

  Future<List<GroupClient>> getGroupClientsById(int roomId) => groupClientDao.getGroupClientsById(roomId);

  Future<GroupClient> getGroupClientById(int roomId, int userId) => groupClientDao.getGroupClientById(roomId, userId);

  Future updateMember(GroupClient client) => groupClientDao.updateMember(client);
}
