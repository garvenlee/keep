import 'package:flutter/material.dart';
import 'package:keep/data/sputil.dart';
import 'package:keep/data/provider/user_provider.dart';

class NoteTagProvider with ChangeNotifier {
  static int _userId = UserProvider.getUserId();
  static List<String> _tags = SpUtil.getStringList('tags-$_userId', defValue: <String>[]);
  static int _selIndex = SpUtil.getInt('noteTagSelection-$_userId', defValue: -1);

  List<String> get tags => _tags;

  // used in note page slidepanel
  int get selectionId  => _selIndex;
  String get selectionTag => _selIndex == -1 ? null : _tags[_selIndex];

  setSelectionId(int selection) {
    _selIndex = selection;
    SpUtil.putInt('noteTagSelection-$_userId', selection);
    notifyListeners();
  }

  void initProvider({bool netAvailable=false}){
    // 在初次使用时, 并判断是否有网络连接，以用于同步更新
    _tags = SpUtil.getStringList('tags-$_userId', defValue: <String>[]);
    if (netAvailable){
      // 获取api
    }
  }

  void addTag(List<String> tag) {
    tag.forEach((val) { 
      if(_tags.indexOf(val) == -1)
        _tags.add(val);
    });
    // _tags.addAll(tag);
    // SpUtil.remove('tags-${UserProvider.getUserId()}');
    notifyListeners();
    SpUtil.putStringList('tags-${UserProvider.getUserId()}', _tags);
  }

  void updateTag(String oldVal, String newVal) {
    int toIndex = _tags.indexOf(oldVal);
    if (toIndex > -1) {
      _tags.removeAt(toIndex);
      _tags.insert(toIndex, newVal);
      notifyListeners();
      // SpUtil.remove('tags-${UserProvider.getUserId()}');
      SpUtil.putStringList('tags-${UserProvider.getUserId()}', _tags);
    }
  }

  void deleteTag(String tag) {
    int toIndex = _tags.indexOf(tag);
    if(toIndex > -1) {
      _tags.removeAt(toIndex);
      notifyListeners();
      // SpUtil.remove('tags-${UserProvider.getUserId()}');
      SpUtil.putStringList('tags-${UserProvider.getUserId()}', _tags);
    }
  }

  static clear() {
    _tags = <String>[];
  }

  @override
  void dispose() {
    super.dispose();
  }
}