import 'package:flutter/foundation.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/sputil.dart';
import 'note.dart';

/// Holds the current searching filter of notes.
class NoteFilter extends ChangeNotifier {
  static final int _userId = UserProvider.getUserId();
  NoteState _noteState;
  // NoteState.values[SpUtil.getInt('noteFilter-$_userId', defValue: 0)];
  static bool _gridView = SpUtil.getBool('gridview-$_userId', defValue: true);
  static bool _slidePanel = false;

  /// The state of note to search.
  NoteState get noteState => _noteState;
  bool get gridView => _gridView;
  bool get showPanel => _slidePanel;

  set noteState(NoteState value) {
    if (value != null && value != _noteState) {
      _noteState = value;
      SpUtil.putInt('noteFilter-$_userId', value.index);
      print('update note state');
      notifyListeners();
    }
  }

  setView() {
    _gridView = !_gridView;
    SpUtil.putBool('gridview-$_userId', _gridView);
    notifyListeners();
  }

  set showPanel(bool value) {
    if(value != null && value != _slidePanel) {
      _slidePanel = value;
      notifyListeners();
    }
  }

  setPanel() {
    _slidePanel = !_slidePanel;
    notifyListeners();
  }

  /// Creates a [NoteFilter] object.
  NoteFilter([this._noteState = NoteState.unspecified]);

  @override
  void dispose() {
    super.dispose();
  }
}
