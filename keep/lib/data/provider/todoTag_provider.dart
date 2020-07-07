import 'package:flutter/material.dart';
import 'package:keep/data/sputil.dart';
import 'package:keep/data/provider/user_provider.dart';

class TodoTagProvider with ChangeNotifier {
  static int _userId = UserProvider.getUserId();
  // static List<String> _tags =
  // SpUtil.getStringList('todo-tags-$_userId', defValue: <String>[]);
  static List<String> _tags = [
    'JavaScript',
    'Python',
    'Java',
    'PHP',
    'C#',
    'C++'
  ];
  static int _selIndex =
      SpUtil.getInt('todoTagSelection-$_userId', defValue: -1);

  List<String> get tags => _tags;

  // used in note page slidepanel
  int get selectionId => _selIndex;
  String get selectionTag => _selIndex == -1 ? null : _tags[_selIndex];

  setSelectionId(int selection) {
    _selIndex = selection;
    SpUtil.putInt('todoTagSelection-$_userId', selection);
    notifyListeners();
  }

  void addTag(List<String> tag) {
    tag.forEach((val) {
      if (_tags.indexOf(val) == -1) _tags.add(val);
    });
    notifyListeners();
    SpUtil.putStringList('todo-tags-${UserProvider.getUserId()}', _tags);
  }

  void updateTag(String oldVal, String newVal) {
    int toIndex = _tags.indexOf(oldVal);
    if (toIndex > -1) {
      _tags.removeAt(toIndex);
      _tags.insert(toIndex, newVal);
      notifyListeners();
      SpUtil.putStringList('todo-tags-${UserProvider.getUserId()}', _tags);
    }
  }

  void deleteTag(String tag) {
    int toIndex = _tags.indexOf(tag);
    if (toIndex > -1) {
      _tags.removeAt(toIndex);
      notifyListeners();
      SpUtil.putStringList('todo-tags-${UserProvider.getUserId()}', _tags);
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
