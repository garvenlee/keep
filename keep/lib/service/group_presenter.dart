import 'package:keep/service/rest_ds.dart';
import 'package:keep/models/group_source.dart';
import 'package:keep/data/repository/group_client_repository.dart';
import 'package:keep/data/repository/group_repository.dart';
// import 'package:keep/BLoC/group_bloc.dart';
// import 'package:keep/BLoC/group_client_bloc.dart';

class GroupPresenter {
  static saveGroups(int userId) async {
    RestDatasource _api = new RestDatasource();
    _api.getGroups(userId).then((List<GroupSource> groups) {
      groups.forEach((group) {
        // final groupBloc = new GroupBloc();
        // final clientsBloc = new GroupClientBloc();
        final groupRepo = new GroupRepository();
        final groupClientRepo = new GroupClientRepository();
        groupRepo.getGroupById(group.group.roomId).then((value) {
          // print(value == null);
          if (value == null)
            groupRepo.newGroup(group.group);
          else
            groupRepo.updateGroup(group.group);
        });
        group.clients.forEach((client) {
          groupClientRepo
              .getGroupClientById(client.roomId, client.userId)
              .then((value) {
            print(value == null);
            if (value == null)
              groupClientRepo.newMember(client);
            else
              groupClientRepo.updateMember(client);
          });
        });
        // groupBloc.dispose();
        // clientsBloc.dispose();
      });
      print('get groups done.');
    }).catchError((Object error) {
      print('still have not groups yet.');
      print(error.toString());
    });
  }
}
