import 'dart:convert';
import 'dart:typed_data';
import 'package:html/parser.dart';
import 'package:keep/data/repository/group_client_repository.dart';
import 'package:keep/data/repository/group_repository.dart';
import 'package:keep/models/group.dart';
import 'package:keep/models/group_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:keep/settings/config.dart';
import 'package:keep/models/storageUrl.dart';
import 'package:keep/BLoC/storage_bloc.dart';
import 'package:keep/BLoC/message_bloc.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/service/rest_ds.dart';
import 'package:keep/models/chat_message.dart';
import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
import 'package:keep/data/repository/message_repository.dart';
import 'package:keep/models/friend.dart';
import 'package:keep/utils/event_util.dart';
import 'package:keep/settings/notification_helper.dart';

/// user info utils
String capitalize(String input) {
  input = input ?? 'user';
  return input.substring(0, 1).toUpperCase() + input.substring(1);
}

MemoryImage txt2Image(String base64Text, {double scale = 1.0}) {
  // print(base64Text);
  var decodeTxt = Base64Decoder().convert(base64Text.split(',')[1]);
  return MemoryImage(decodeTxt, scale: scale);
}

/// notification relevant function
void addBadge(int count) {
  FlutterAppBadger.updateBadgeCount(count);
}

void removeBadge() {
  FlutterAppBadger.removeBadge();
}

void showHintText(String hintText) {
  BotToast.showText(
      text: hintText,
      duration: Duration(seconds: NotificationConfig.seconds),
      onlyOne: NotificationConfig.onlyOne,
      clickClose: NotificationConfig.clickClose,
      crossPage: NotificationConfig.crossPage,
      backButtonBehavior: NotificationConfig.backButtonBehavior,
      align: Alignment(0, NotificationConfig.align),
      animationDuration:
          Duration(milliseconds: NotificationConfig.animationMilliseconds),
      animationReverseDuration: Duration(
          milliseconds: NotificationConfig.animationReverseMilliseconds),
      textStyle: TextStyle(
          color: Color(NotificationConfig.fontColor),
          fontSize: NotificationConfig.fontSize.toDouble()),
      borderRadius:
          BorderRadius.circular(NotificationConfig.borderRadius.toDouble()),
      backgroundColor: Color(NotificationConfig.backgroundColor),
      contentColor: Color(NotificationConfig.contentColor));
}

void showNotification(
    {BuildContext context,
    String title,
    String username,
    String body,
    String payload}) {
  BotToast.showNotification(
      leading: (cancel) => SizedBox.fromSize(
          size: const Size(48, 48),
          child: InkWell(
              onTap: cancel,
              child: CircleAvatar(
                // backgroundColor: Colors.white30,
                backgroundColor: Colors.black54,
                radius: 24,
                child: Center(
                  child: Text(
                    username != null && username.isNotEmpty
                        ? capitalize(username[0])
                        : 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ))),
      title: (_) => Text(title),
      subtitle: (_) => Text("$username say: $body",
          softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: (cancel) => IconButton(
            icon: Icon(Icons.cancel),
            onPressed: cancel,
          ),
      onTap: () => tapAction(context, payload),
      onLongPress: () {
        BotToast.showText(text: 'Long press toast');
      },
      enableSlideOff: NotificationConfig.enableSlideOff,
      backButtonBehavior: NotificationConfig.backButtonBehavior,
      crossPage: NotificationConfig.crossPage,
      contentPadding: EdgeInsets.all(NotificationConfig.msgContentPadding),
      onlyOne: NotificationConfig.onlyOne,
      animationDuration:
          Duration(milliseconds: NotificationConfig.animationMilliseconds),
      animationReverseDuration: Duration(
          milliseconds: NotificationConfig.animationReverseMilliseconds),
      duration: Duration(seconds: NotificationConfig.msgNotificationDelay));
}

tapAction(BuildContext context, String payload) {
  if (payload != null && payload.length > 0) {
    debugPrint("payload : $payload");
    int idx = payload.indexOf("-");
    int typeId = int.parse(payload.substring(0, idx));
    int targetId = int.parse(payload.substring(idx + 1));
    // List<String> payData = payload.split(pattern)
    // int typeId = int.parse(payData[0]);
    // int targetId = int.parse(payData[1]);
    // selectNotificationSubject.add('0-0');
    _cancelNotification(targetId);
    handleTapNavAction(context, typeId, targetId);
  }
}

void handleTapNavAction(BuildContext context, int typeId, int targetId) async {
  // debugPrint('enter ===============>');
  final msgRepo = new MessageRepository();
  switch (typeId) {
    case 0:
      debugPrint('do not have any notification.');
      break;
    case 1:
      debugPrint('enter to nav to user chat screen===============>');
      if (targetId > 0) {
        Friend friend = FriendProvider.getFriendById(targetId);
        msgRepo.getMessagesByRecvId(1, targetId).then((messages) {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            debugPrint('navigation==========================>');
            return ChatScreen(userType: 1, friend: friend, messages: messages);
          }));
        });
      } else {
        final groupRepo = GroupRepository();
        final groupClientRepo = GroupClientRepository();
        Group group = await groupRepo.getGroupById(-targetId);
        List<GroupClient> clients =
            await groupClientRepo.getGroupClientsById(-targetId);
        Map<int, GroupClient> members = {};
        clients.forEach((client) => members[client.userId] = client);
        msgRepo.getMessagesByRecvId(2, -targetId).then((messages) {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            debugPrint('navigation==========================>');
            return ChatScreen(
                userType: 2,
                group: group,
                members: members,
                messages: messages);
          }));
        });
      }
      break;
    case 2:
      Friend friend = FriendProvider.getFriendById(targetId);
      // _cancelNotification(targetId);
      Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
        return ChatScreen(userType: 1, friend: friend, messages: []);
      }));
      break;
    case 3:
      break;
  }
}

void _triggerMsgNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    {int id,
    String title,
    String username,
    String body,
    String payload = '0-0'}) async {
  await _showNotification(flutterLocalNotificationsPlugin,
      id: id,
      title: title,
      body: '${capitalize(username)} say:  $body',
      payload: payload,
      category: 'Chat-Message');
}

void _triggerFriendNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    {int fsId,
    String title,
    String username,
    String payload = '0-0'}) async {
  await _showNotification(flutterLocalNotificationsPlugin,
      id: fsId,
      title: title,
      body: '${capitalize(username)} 已成为新的好友',
      payload: payload,
      category: 'Friend-Request');
}

// void _configNotification() {
//   flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//   var android = new AndroidInitializationSettings('login_logo');
//   var iOS = new IOSInitializationSettings();
//   var initSetttings = new InitializationSettings(android, iOS);
//   flutterLocalNotificationsPlugin.initialize(initSetttings,
//       onSelectNotification: _onSelectNotification);
// }

void onChatCallback(stream) {
  UserMessage msg = UserMessage.fromMap(stream);
  print('receive new message =====================>');
  // print(stream['creator_id']);
  var iid =
      stream['chat_type'] == 1 ? stream['creator_id'] : -stream['recipient_id'];
  var args = {
    // "id": (stream['create_at'] / 1000000).floor(),
    "id": iid,
    "title": "New Message",
    "username": stream['creator_name'],
    "body": stream['message_body'],
    "payload": '1-$iid'
  };
  final msgBloc = new MessageBloc();
  print(args);
  // print(args);
  msgBloc.addMessage(msg).then((_) {
    // bus.emit('scratchAllMessages', true);
    addBadge(1);
    showNotification(
        context: stream['context'],
        title: "New Message",
        username: stream['creator_name'],
        body: stream['message_body'],
        payload: args['payload']);
    _triggerMsgNotification(flutterLocalNotificationsPlugin,
        id: args['id'],
        title: args['title'],
        username: args['username'],
        body: args['body']);
  });
}

void onChatsCallback(stream) {
  if (!stream['error']) {
    List<UserMessage> messages = [];
    stream['messages'].forEach((item) {
      UserMessage msg = UserMessage.fromMap(item);
      messages.add(msg);
    });
    final msgBloc = new MessageBloc();

    // messages
    //     .sort((left, right) => (left.createAt > right.createAt ? 1 : 0));
    msgBloc.addAllMessages(messages).then((_) {
      msgBloc.getMessages();
      addBadge(messages.length);
      _showMessagingNotification(stream['messages'], stream['context']);
    });
  }
}

void onFriendRequestCallback(stream) {
  var args = {
    "uid": stream['userOne']['userId'],
    "title": "新的好友提醒",
    "username": stream['userOne']['username'],
    "creator_id": stream['userOne']['creator_id']
  };
  FriendProvider.addFriend(Friend.fromJson(stream['userOne']));
  addBadge(1);
  // showNotification();
  _triggerFriendNotification(
    flutterLocalNotificationsPlugin,
    fsId: args['uid'],
    title: args['title'],
    username: args['username'],
  );
  // 此处默认接受好友请求，后续需要开发好友请求显示页面
}

void onFriendsRequestCallback(stream) {
  if (!stream['error']) {
    stream['friends'].forEach(
        (friendJson) => FriendProvider.addFriend(Friend.fromMap(friendJson)));
    addBadge(stream['friends'].length);
    stream['friends'].forEach((item) {
      // showNotification();
      var args = {
        "uid": item['userId'],
        "title": "新的好友提醒",
        "username": item['username'],
        "creator_id": item['creator_id']
      };
      _triggerFriendNotification(
        flutterLocalNotificationsPlugin,
        fsId: args['uid'],
        title: args['title'],
        username: args['username'],
      );
    });
  }
}

Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    {int id,
    String title,
    String body,
    String groupKey,
    String payload,
    String category = 'p2p'}) async {
  var androidPlatformChannelSpecifics =
      AndroidNotificationDetails('$id', "$id'name", 'own by $id',
          // importance: Importance.Max,
          // priority: Priority.High,
          category: category,
          groupKey: groupKey ?? '$id');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(id, title, body, platformChannelSpecifics, payload: payload);
}

Future<void> _cancelNotification(int targetId) async {
  print('cancel $targetId');
  await flutterLocalNotificationsPlugin.cancel(targetId);
}

Future<void> _showMessagingNotification(stream, context) async {
  stream
      .sort((left, right) => (left['create_at'] > right['create_at'] ? 1 : 0));
  Map<Person, List<Message>> messages = {};
  Map<Person, int> chatType = {};
  stream.forEach((item) {
    var person = Person(
        name: item['creator_name'],
        key: item['creator_id'].toString(),
        uri: 'uid:${item['creator_id']}');
    if (messages[person] == null) messages[person] = <Message>[];
    chatType[person] = item['chat_type'];
    messages[person].add(Message(item['message_body'],
        DateTime.fromMillisecondsSinceEpoch(item['create_at']), person));
  });
  messages.forEach((key, value) {
    _showOnePersonMessageNotification(
        flutterLocalNotificationsPlugin, key, value, chatType[key]);
  });
  // _showGroupedNotifications(flutterLocalNotificationsPlugin);
  showNotification(
      context: context,
      title: "New Message",
      username: stream[0]['creator_name'],
      body: stream[0]['message_body'],
      payload: '1-${stream[0]['creator_id']}');
  bus.emit('scratchAllMessages');
}

Future<void> _showOnePersonMessageNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    Person person,
    List<Message> messages,
    int chatType) async {
  int uid = int.parse(person.key);
  print('one person messages length is ${messages.length}');
  var messagingStyle = MessagingStyleInformation(person,
      groupConversation: chatType == 2,
      conversationTitle: 'Chat-Messages',
      htmlFormatContent: true,
      htmlFormatTitle: true,
      messages: messages);
  var androidPlatformChannelSpecifics =
      AndroidNotificationDetails('$uid', "$uid'name", 'own by $uid',
          channelShowBadge: true,
          // importance: Importance.Max,
          // priority: Priority.High,
          category: 'chat-messages',
          styleInformation: messagingStyle);
  var platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, null);
  await flutterLocalNotificationsPlugin.show(
      uid, 'message title', 'message body', platformChannelSpecifics);
  // payload: '1-$uid');
}

Future<void> _showGroupedNotifications(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
) async {
  var groupKey = 'com.android.example.WORK_EMAIL';
  var groupChannelId = 'grouped channel id';
  var groupChannelName = 'grouped channel name';
  var groupChannelDescription = 'grouped channel description';
  // example based on https://developer.android.com/training/notify-user/group.html
  var firstNotificationAndroidSpecifics = AndroidNotificationDetails(
      groupChannelId, groupChannelName, groupChannelDescription,
      importance: Importance.Max, priority: Priority.High, groupKey: groupKey);
  var firstNotificationPlatformSpecifics =
      NotificationDetails(firstNotificationAndroidSpecifics, null);
  await flutterLocalNotificationsPlugin.show(1, 'Alex Faarborg',
      'You will not believe...', firstNotificationPlatformSpecifics);
  var secondNotificationAndroidSpecifics = AndroidNotificationDetails(
      groupChannelId, groupChannelName, groupChannelDescription,
      importance: Importance.Max, priority: Priority.High, groupKey: groupKey);
  var secondNotificationPlatformSpecifics =
      NotificationDetails(secondNotificationAndroidSpecifics, null);
  await flutterLocalNotificationsPlugin.show(
      2,
      'Jeff Chang',
      'Please join us to celebrate the...',
      secondNotificationPlatformSpecifics);

  // create the summary notification to support older devices that pre-date Android 7.0 (API level 24).
  // this is required is regardless of which versions of Android your application is going to support
  var lines = List<String>();
  lines.add('Alex Faarborg  Check this out');
  lines.add('Jeff Chang    Launch Party');
  var inboxStyleInformation = InboxStyleInformation(lines,
      contentTitle: '2 messages', summaryText: 'janedoe@example.com');
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      groupChannelId, groupChannelName, groupChannelDescription,
      styleInformation: inboxStyleInformation,
      groupKey: groupKey,
      setAsGroupSummary: true);
  var platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, null);
  await flutterLocalNotificationsPlugin.show(
      3, 'Attention', 'Two messages', platformChannelSpecifics);
}

/// storage box url handle function
Future<String> _networkImageToByte(String url) async {
  Uint8List byteImage = await networkImageToByte(url);
  return base64Encode(byteImage);
}

void handleURL(url, tags) async {
  print('trigger the save_url');
  final RestDatasource _api = new RestDatasource();
  final collectionBloc = new CollectionBloc();
  final isExist = await collectionBloc.getCollectionByURL(url);
  print(isExist);
  if (!isExist) {
    _api
        .getUrlContent(url,
            headers: {
              'Accept': '*/*',
              'Accept-Language': 'en-US,en;q=0.8',
              'Cache-Control': 'max-age=0',
              'User-Agent':
                  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36',
              'Connection': 'keep-alive',
              'Referer': 'http://www.baidu.com/'
            },
            isJson: false)
        .then((res) {
      var document = parse(res);
      // print(document.getElementsByTagName('title')[0].text);
      String title = document.getElementsByTagName('title')[0].text;
      String imgUrl = '';
      for (final img in document.getElementsByTagName('img')) {
        if (img.attributes['src'] != null &&
            (img.attributes['src'].endsWith('jpg') ||
                img.attributes['src'].endsWith('jpeg') ||
                img.attributes['src'].endsWith('png'))) {
          imgUrl = img.attributes['src'];
          break;
        }
      }
      if (imgUrl != '') {
        String headerType;
        if (imgUrl.endsWith('jpg')) {
          headerType = "data:image/jpg;base64,";
        } else if (imgUrl.endsWith('jpeg')) {
          headerType = "data:image/jpeg;base64,";
        } else {
          headerType = "data:image/png;base64,";
        }
        _networkImageToByte(imgUrl).then((avatar) {
          // print(tags);
          StorageUrl collection = StorageUrl(
              url: url,
              title: title,
              tags: tags.split(' '),
              avatar: headerType + avatar,
              createAt: DateTime.now().millisecondsSinceEpoch);
          collectionBloc.addCollection(collection);
        });
      } else {
        String avatar = 'null';
        StorageUrl collection = StorageUrl(
            url: url,
            title: title,
            avatar: avatar,
            tags: tags.split(' '),
            createAt: DateTime.now().millisecondsSinceEpoch);
        collectionBloc.addCollection(collection);
      }
    });
  } else {
    showHintText('already exist.');
  }
  // collectionBloc.dispose();
}

/// url_launcher relevant function
Future<void> launchInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launchInWebViewOrVC(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    );
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launchInWebViewWithJavaScript(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      enableJavaScript: true,
    );
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launchInWebViewWithDomStorage(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      enableDomStorage: true,
    );
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launchUniversalLinkIos(String url) async {
  if (await canLaunch(url)) {
    final bool nativeAppLaunchSucceeded = await launch(
      url,
      forceSafariVC: false,
      universalLinksOnly: true,
    );
    if (!nativeAppLaunchSucceeded) {
      await launch(
        url,
        forceSafariVC: true,
      );
    }
  }
}

Widget launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
  if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
  } else {
    return const Text('');
  }
}

Future<void> makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
