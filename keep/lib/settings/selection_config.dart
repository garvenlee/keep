
// chat screen rightTop dropdown menu list item
import 'package:flutter/material.dart';
import 'package:keep/data/database_helper.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/service/socket_util.dart';

Map<String, Icon> chatSelections = {
  'Search': Icon(Icons.search, color: Colors.grey),
  'Mute Notifications': Icon(Icons.speaker_notes_off, color: Colors.grey),
  'Chat history': Icon(Icons.history, color: Colors.grey),
  'Clear history': Icon(Icons.clear_all, color: Colors.grey)
};

Map<String, Function> chatSelectionTapAction = {
  "Search": () {},
  "Mute Notifications": () {},
  "Chat hisory": () {},
  "Clear history": () {}
};

// setting main page rightTop dropdown menu list item
Map<String, Icon> settingSelection = {
  "Edit name": Icon(Icons.edit, color: Colors.grey),
  "Log out": Icon(Icons.exit_to_app, color: Colors.grey)
};

Map<String, Function> settingSelctionTapAction = {
  "Edit name": nav2editName,
  "Log out": logout
};

Map<String, Icon> userProfileSelection = {
  "Edit contact": Icon(Icons.edit, color: Colors.grey),
  "Delete contact": Icon(Icons.delete, color: Colors.grey),
  "Block contact": Icon(Icons.block, color: Colors.grey)
};

Map<String, Function> userProfileSelectionTapAction = {
  "Edit contact": () {},
  "Delete contact": () {},
  "Block contact": () {},
};


Function nav2editName(BuildContext context) {
  return () {
    // Navigator.of(context).push(route);
    print('edit name');
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pop();
    });
  };
}

Function logout(BuildContext context) {
  return () {
    print('disconnect.....');
    new SocketUtil().socket
      ..then((socket) {
        print('disconnect=======================>');
        socket.emit('disconnect', ['logout']);
        SocketUtil.disconnect();
        print('done<=============================');
      }); // close socket connection
    DatabaseHelper.closeDb();
    Future.delayed(Duration.zero, () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
    });
    UserProvider.clearUser();
    FriendProvider.clearFriends();
  };
}