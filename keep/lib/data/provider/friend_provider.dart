import 'package:flutter/material.dart';
import 'package:keep/service/rest_ds.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/sputil.dart';

class FriendProvider with ChangeNotifier {
  static Map<int, Friend> _idMapFriend = {};
  static List<Friend> _friends = <Friend>[];

  static bool get hasFriends => getFriends().length > 0;

  static saveFriends(int userId) async {
    _friends = getFriends();
    RestDatasource _api = new RestDatasource();
    _api.getFriends(userId).then((List<Friend> friends) {
      print('friends============>');
      List<Friend> unionFriends = [];
      friends.forEach((friend) {
        unionFriends.add(friend);
      });
      for (var i = 0; i < _friends.length; i++) {
        bool checkSame = false;
        for (var i = 0; i < friends.length; i++) {
          if (_friends[i].userId == friends[i].userId) {
            checkSame = true;
            break;
          }
        }
        if (!checkSame) unionFriends.add(_friends[i]);
      }
      unionFriends.forEach((friend) {
        _idMapFriend[friend.userId] = friend;
      });
      _friends = unionFriends;
      SpUtil.putObjectList("friends-$userId", _friends);
      print('get friends done.');
    }).catchError((Object error) {
      print('still have not friends yet.');
      print(error.toString());
    });
  }

  static clearFriends() {
    _friends = [];
    _idMapFriend = {};
  }

  static getFriends() {
    return _friends.length > 0
        ? _friends
        : SpUtil.getObjList(
                "friends-${UserProvider.getUserId()}", Friend.fromMap) ??
            <Friend>[];
  }

  static Friend getFriendById(int userId) {
    if (_idMapFriend.length == 0) {
      if (_friends.length == 0) _friends = getFriends();
      _friends.forEach((friend) {
        _idMapFriend[friend.userId] = friend;
      });
    }
    return _idMapFriend[userId];
  }

  static addFriend(Friend friend) {
    List<Friend> friends = [];
    getFriends().forEach((val) => friends.add(val));
    friends.add(friend);
    _idMapFriend[friend.userId] = friend;
    SpUtil.putObjectList("friends-${UserProvider.getUserId()}", friends);
    _friends = friends;
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
