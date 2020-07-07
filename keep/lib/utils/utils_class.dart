// upload image data wrapper used to callback
class UploadPopReceiver {
  Map<String, dynamic> stream;
  UploadPopReceiver(this.stream);
}

class SelTagReceiver {
  Map<String, dynamic> stream;
  SelTagReceiver(this.stream);
}

enum ConnectivityStatus {
  // WiFi,
  // Cellular,
  Available,
  Offline,
  Unavailable
}

class ClipBoardData {
  ClipBoardData(this.text);
  String text;
}