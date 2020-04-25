import 'package:keep/data/rest_ds.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/utils/sputil.dart';

class FriendProvider {
  static List<Friend> _friends = <Friend>[];

  static Future<void> saveFriends(int userId) async {
    RestDatasource _api = new RestDatasource();
    _api.getFriends(userId).then((List<Friend> friends) {
      _friends = friends;
      SpUtil.putObjectList("friends", friends);
      print('get friends done.');
    }).catchError((Object error) {
      print('still have not friends yet.');
      print(error.toString());
    });
  }

  static getFriends() {
    print(_friends);
    return _friends.length > 0
        ? _friends
        : SpUtil.getObjList("friends", Friend.fromMap) ?? <Friend>[];
  }

  static getUsername(int userId) {
    List<Friend> friends = getFriends();
    String username;
    friends.forEach((friend) {
      print('friend name is..................>');
      // print(friend.username);
      if (friend.userId == userId) {
        print('get friends===================================>');
        username = friend.username;
      }
    });
    return username;
  }

  static addFriend(Friend friend) {
    List<Friend> friends = getFriends();
    friends.add(friend);
    print(friends);
    // SpUtil.remove("friends");
    SpUtil.putObjectList("friends", friends);
    _friends.add(friend);
    print(_friends);
  }

  static isExist(String email) {
    List<Friend> friends = getFriends();
    bool val = false;
    for (final friend in friends) {
      if (friend.email == email) {
        val = true;
        break;
      }
    }
    return val;
  }
}
