import 'package:flutter/material.dart';
import 'package:keep/data/sputil.dart';
import 'package:keep/data/provider/user_provider.dart';

class BadgeNumProvider  with ChangeNotifier  {
  static int _userId = UserProvider.getUserId();
  static int _number = SpUtil.getInt('badgeNumber-$_userId', defValue: 0);
  int get badgeNumber => _number;
  addBadgeNumber(int value) {
    _number += value;
    notifyListeners();
    SpUtil.putInt('badgeNumber-$_userId', _number);
  }

  clear() {
    if(_number > 0) {
      _number = 0;
      notifyListeners();
      SpUtil.putInt('badgeNumber-$_userId', 0);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}