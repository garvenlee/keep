import 'package:keep/service/rest_ds.dart';
import 'package:keep/models/chat_message.dart';
// import 'package:keep/BLoC/message_bloc.dart';
import 'package:keep/data/repository/message_repository.dart';

class MessagePresenter {
  static saveMessages(int userId) async {
    RestDatasource _api = new RestDatasource();
    _api.getMessages(userId).then((List<UserMessage> messages) {
      // final msgBloc = new MessageBloc();
      final msgRepo = new MessageRepository();
      messages.forEach((message) {
        msgRepo
            .getMessage(
                createAt: message.createAt, creatorId: message.creatorId)
            .then((value) {
          if (value == null) msgRepo.insertMessage(message);
        });
      });
      print('get groups done.');
      // msgBloc.dispose();
    }).catchError((Object error) {
      print('still have not messages yet.');
      print(error.toString());
    });
  }
}
