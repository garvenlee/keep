import 'package:keep/models/group_client.dart';
import 'package:keep/data/repository/group_client_repository.dart';
import 'dart:async';

class GroupClientBloc {
  //Get instance of the Repository
  final _groupClientRepository = GroupClientRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers

  final _groupClientController = StreamController<List<GroupClient>>.broadcast();

  get groupClients => _groupClientController.stream;

  GroupClientBloc() {
    getGroupClients();
  }

  getGroupClients({String whereString, List<String> query}) async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _groupClientController.sink.add(await _groupClientRepository.getAllGroupClients(
        whereString: whereString, query: query));
  }

  addMember(GroupClient client) async  {
    await _groupClientRepository.newMember(client);
    getGroupClients();
  }

  getClientById(int roomId, int userId) async =>
    await _groupClientRepository.getGroupClientById(roomId, userId);


  updateMember(GroupClient client) async => await _groupClientRepository.updateMember(client);

  dispose() {
    _groupClientController.close();
  }
}
