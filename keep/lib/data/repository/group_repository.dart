import 'package:keep/data/dao/group_dao.dart';
import 'package:keep/models/group.dart';
// import 'package:keep/utils/event_util.dart';

class GroupRepository {
  final GroupDao groupDao = new GroupDao();

  Future getAllGroups({String whereString, List<String> query}) =>
      groupDao.getGroups(whereString: whereString, query: query);

  Future newGroup(Group group) => groupDao.createGroup(group);

  Future<Group> getGroupById(int roomId) => groupDao.getGroupById(roomId);

  Future updateGroup(Group group) => groupDao.updateGroup(group);
}
