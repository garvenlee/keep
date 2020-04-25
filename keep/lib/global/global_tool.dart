import 'package:flutter/material.dart';
// import 'package:keep/utils/event_util.dart';
// import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/utils/socket_util.dart';

// Text Style
final entranceStyle = TextStyle(fontFamily: 'Montserrat', fontSize: 15.0);

// statusBar
final List<Icon> iconLists = [
  Icon(
    Icons.check,
    color: Colors.greenAccent,
  ),
  Icon(
    Icons.error_outline,
    color: Colors.greenAccent,
  )
];
final iconIndicator = {"success": 0, "error": 1};

// form validate
final RegExp emailReg =
    new RegExp(r'^[A-Za-z0-9]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
final RegExp codeReg = new RegExp(r'[0-9]{6}');
final RegExp urlRegExp = new RegExp(
    r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

String judgePwd(String val) {
  if (val.isEmpty) {
    return "password cannot be empty!";
  } else if (val.length < 8) {
    return "must be at least 8 characters!";
  } else if (val.length > 15) {
    return "must be at most 15 characters!";
  } else {
    return null;
  }
}

String judgeConfirmPwd(String val, String cmpString) {
  if (val.isEmpty) {
    return "password cannot be empty!";
  } else if (val.length < 8) {
    return "must be at least 8 characters!";
  } else if (val.length > 15) {
    return "must be at most 15 characters!";
  } else if (val != cmpString) {
    return "two password is not the same.";
  } else {
    return null;
  }
}

String judgeEmail(String val) {
  if (val.isEmpty) return "email don't be empty!";
  return !emailReg.hasMatch(val) ? "Please check the email's format" : null;
}

String judgeCode(String val) {
  if (val.isEmpty) {
    return "code cannot be empty!";
  }
  if (!(val.length == 6)) {
    return "length must be 6";
  } else {
    return !codeReg.hasMatch(val) ? "no character in code!" : null;
  }
}

String capitalize(String input) {
  return input.substring(0, 1).toUpperCase() + input.substring(1);
}

bool judgeUrl(String text) {
  // final urlMatches = urlRegExp.allMatches(text);
  // List<String> urls = urlMatches.map(
  //       (urlMatch) => text.substring(urlMatch.start, urlMatch.end))
  //   .toList();
  // urls.forEach((x) => print(x));
  return urlRegExp.hasMatch(text);
}

// upload image data wrapper used to callback
class UploadPopReceiver {
  Map<String, dynamic> stream;
  UploadPopReceiver(this.stream);
}

// display user online or offline status
Map<String, String> statusIndicator = {
  'active': '',
  'inactive': 'No Internet connection available',
  'offline': "Sorry, You're offline"
};

Map<String, Color> statusColor = {
  'active': Colors.white,
  'inactive': Colors.black.withAlpha(160),
  'offline': Colors.red.withAlpha(150)
};

Map<String, Color> statusTextColor = {
  'inactive': Colors.white38,
  'offline': Colors.black
};

// distinguish network status
Map<String, String> loginErrorHint = {
  "loginError": "Please check your email or password.",
  "netError": "Please check your internet."
};

// chat screen rightTop dropdown menu list item
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
    Future.delayed(Duration.zero, () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
    });
    // SystemChannels.platform
    //     .invokeMethod('SystemNavigator.pop');
  };
}
