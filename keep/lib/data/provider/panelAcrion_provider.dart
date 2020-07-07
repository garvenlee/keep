import 'package:flutter/material.dart';

class StoragePanelAction  with ChangeNotifier  {
  static bool _enterTag = false;
  bool get enterTag => _enterTag;
  set enterTag(bool value) {
    if(value != null && value != _enterTag) {
      _enterTag = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}