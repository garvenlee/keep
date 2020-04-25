import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardStream {
  static final clipboardContentStream = StreamController<String>.broadcast();

  final Timer clipboardTriggerTime = Timer.periodic(
    const Duration(seconds: 2),
    (timer) {
      Clipboard.getData('text/plain').then((clipboarContent) {
        String url = clipboarContent != null ? clipboarContent.text : '';
        print('Clipboard content ${url.length}');

        clipboardContentStream.add(url);
      });
    },
  );

  Stream get clipboardText => clipboardContentStream.stream;

  clear() async {
    await Clipboard.setData(ClipboardData(text: ''));
  }

  void dispose() {
    clipboardContentStream.close();

    clipboardTriggerTime.cancel();
  }
}
