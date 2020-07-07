import 'package:bot_toast/bot_toast.dart';

const String httpUrl = 'https://86dce6b0f208.ngrok.io';
const String baseIP = '192.168.124.12';
const int port = 42300;

class NotificationConfig {
  NotificationConfig._();
  static const bool clickClose = false;
  static const double align = 0.8;
  static const int fontSize = 17;
  static const int borderRadius = 8;
  static const int fontColor = 0xFFFFFFFF;
  static const int backgroundColor = 0x00000000;
  static const int contentColor = 0x8A000000;
  static const bool enableSlideOff = true;
  static const bool onlyOne = true;
  static const bool crossPage = true;
  static const int seconds = 2;
  static const int msgNotificationDelay = 3;
  static const double contentPadding = 2;
  static const double msgContentPadding = 8;
  static const int animationMilliseconds = 200;
  static const int animationReverseMilliseconds = 200;
  static const BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
}
