import 'dart:async';

import 'package:flutter/services.dart';
import 'package:keep/utils/utils_class.dart' show ClipBoardData;

class ClipboardStream {
  static final clipboardContentStream =
      StreamController<ClipBoardData>.broadcast();

  final Timer clipboardTriggerTime = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      Clipboard.getData('text/plain').then((clipboarContent) {
        String url = clipboarContent != null ? clipboarContent.text : '';
        print('Clipboard content ${url.length}');
        clipboardContentStream.add(ClipBoardData(url));
      });
    },
  );

  Stream<ClipBoardData> get clipboardText => clipboardContentStream.stream;

  clear() async {
    await Clipboard.setData(ClipboardData(text: ''));
  }

  void dispose() {
    clipboardContentStream.close();
    clipboardTriggerTime.cancel();
  }
}
