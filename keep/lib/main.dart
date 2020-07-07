import 'dart:async';
import 'dart:ui';
import 'package:keep/models/group_source.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
// import 'package:reorderables/generated/i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:keep/settings/routes.dart';
import 'package:keep/settings/notification_helper.dart';
import 'package:keep/settings/sit_localization_delegate.dart'
    show SitLocalizationsDelegate;

import 'package:keep/data/sputil.dart';
import 'package:keep/data/provider/user_provider.dart' show UserProvider;
import 'package:keep/data/provider/panelAcrion_provider.dart'
    show StoragePanelAction;
import 'package:keep/utils/utils_class.dart'
    show ClipBoardData, ConnectivityStatus;
// import 'package:keep/BLoC/message_bloc.dart';
import 'package:keep/BLoC/clipboard_listener.dart';
// import 'package:keep/BLoC_provider/bloc_provider.dart';
import 'package:keep/service/connectivity_service.dart';

import 'package:keep/models/friend.dart';
import 'package:keep/UI/Login/login_screen.dart';
import 'package:keep/UI/Home/Noting/note_editor.dart';
import 'package:keep/UI/Home/Chat/NewGroup/AddGroupName/add_group_name.dart';
import 'package:keep/UI/Home/Chat/Profile/user_profile.dart';
import 'package:keep/UI/Home/Chat/Profile/group_profile.dart';

// 同步
void initSharedPref() async => await SpUtil.getInstance();

void initBadgeConfig() async => await FlutterAppBadger.isAppBadgeSupported()
    .then((val) => debugPrint(val.toString()));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initSharedPref(); // sync sharedpreference
  initBadgeConfig();
  initNotification();
  _requestIOSPermissions();
  runApp(MyApp());
}

void initNotification() async {
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid =
      AndroidInitializationSettings('login_logo');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    // selectNotificationSubject.skip(1);
    selectNotificationSubject.sink.add(payload);
    // selectNotificationSubject.add(payload);
  });
}

void _requestIOSPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

class MyApp extends StatelessWidget {
  // final msgBloc = MessageBloc();
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/images/screen2.jpg"), context);
    // app statusBar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // statusBarColor: Colors.blue[300],
      statusBarColor: Colors.cyan,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    ScreenUtil.init(width: 1080, height: 2340, allowFontScaling: false);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => StoragePanelAction()),
          StreamProvider<ConnectivityStatus>(
              create: (context) => ConnectivityService().stream),
          StreamProvider<ClipBoardData>(
              create: (context) => ClipboardStream().clipboardText),
          // FutureProvider<ClipboardData>(create: (context) => Clipboard.getData('text/plain'))
        ],
        child: RefreshConfiguration(
            headerBuilder: () =>
                WaterDropHeader(), // 配置默认头部指示器,假如你每个页面的头部指示器都一样的话,你需要设置这个
            footerBuilder: () => ClassicFooter(), // 配置默认底部指示器
            headerTriggerDistance: 80.0, // 头部触发刷新的越界距离
            springDescription: SpringDescription(
                stiffness: 170,
                damping: 16,
                mass: 1.9), // 自定义回弹动画,三个属性值意义请查询flutter api
            maxOverScrollExtent: 100, //头部最大可以拖动的范围,如果发生冲出视图范围区域,请设置这个属性
            maxUnderScrollExtent: 0, // 底部最大可以拖动的范围
            enableScrollWhenRefreshCompleted: true,
            enableLoadingWhenFailed: true, //在加载失败的状态下,用户仍然可以通过手势上拉来触发加载更多
            hideFooterWhenNotFull: false, // Viewport不满一屏时,禁用上拉加载更多功能
            enableBallisticLoad: true, // 可以通过惯性滑动触发加载更多
            child: MaterialApp(
              builder: BotToastInit(),
              navigatorObservers: [BotToastNavigatorObserver()],
              debugShowCheckedModeBanner: false,
              title: 'Keep Note',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              onGenerateRoute: _onGenerateRouteConfig,
              initialRoute: '/',
              routes: routes,
              localizationsDelegates: [
                // const GeneratedLocalizationsDelegate(),
                const SitLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                RefreshLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en'),
                const Locale('zh'),
                // const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
                // const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
                // const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
              ],
              localeResolutionCallback:
                  (Locale locale, Iterable<Locale> supportedLocales) {
                print("change language");
                return locale;
              },
            )));
  }

  Route _onGenerateRouteConfig(RouteSettings settings) {
    MaterialPageRoute nextRoute;
    switch (settings.name) {
      case '/hold-login':
        var data = settings.arguments as Map<String, String>;
        debugPrint(data['email']);
        nextRoute =
            MaterialPageRoute(builder: (_) => LoginScreen(data['email']));
        break;
      case '/note':
        final note = (settings.arguments as Map ?? {})['note'];
        final uid = (settings.arguments as Map ?? {})['uid'];
        nextRoute =
            MaterialPageRoute(builder: (_) => NoteEditor(note: note, uid: uid));
        break;
      case '/addGroupName':
        final selFriends = (settings.arguments as Map ?? {})['friends'];
        nextRoute = MaterialPageRoute(
            builder: (_) => AddGroupName(selFriends: selFriends));
        break;
      case '/userProfile':
        final parseData = (settings.arguments as Map ?? {});
        final user = parseData['user'];
        final pickname = parseData['pickname'];
        user['pickname'] = pickname;
        nextRoute = MaterialPageRoute(
            builder: (_) => UserProfile(user: Friend.fromMap(user)));
        break;
      case '/groupProfile':
        final group =
            GroupSource.decodeStr((settings.arguments as Map ?? {})['group']);
        nextRoute =
            MaterialPageRoute(builder: (_) => GroupProfile(group: group));
    }
    return nextRoute;
  }
}
