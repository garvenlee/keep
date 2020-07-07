import 'package:keep/models/group.dart';
import 'package:keep/data/repository/group_repository.dart';
import 'dart:async';

class GroupBloc {
  //Get instance of the Repository
  final _groupRepository = GroupRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers

  final _groupController = StreamController<List<Group>>.broadcast();

  get groups => _groupController.stream;

  GroupBloc() {
    getGroups();
  }

  getGroups({String whereString, List<String> query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _groupController.sink.add(await _groupRepository.getAllGroups(
        whereString: whereString, query: query));
  }

  addGroup(Group group) async {
    await _groupRepository.newGroup(group);
    getGroups();
  }

  Future<Group> getGroupById(int groupId) async {
    return await _groupRepository.getGroupById(groupId);
  }

  Future updateGroup(Group group) =>
    _groupRepository.updateGroup(group);

  dispose() {
    _groupController.close();
  }
}
