import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep/BLoC/note_bloc.dart';
import 'package:keep/UI/Home/Noting/note_presenter.dart';
import 'package:keep/widget/color_picker.dart';
import 'package:provider/provider.dart';

import 'package:keep/settings/icons.dart';
import 'package:keep/models/note.dart';
import 'package:keep/utils/notes_service.dart';
import 'package:keep/settings/styles.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/data/provider/noteTag_provider.dart';
// import 'package:keep/service/note_presenter.dart';
import 'package:keep/widget/note_actions.dart';
import 'package:keep/utils/tools_function.dart';

/// The editor of a [Note], also shows every detail about a single note.
class NoteEditor extends StatefulWidget {
  /// Create a [NoteEditor],
  /// provides an existed [note] in edit mode, or `null` to create a new one.
  const NoteEditor({Key key, this.note, this.uid}) : super(key: key);
  final int uid;
  final Note note;

  @override
  State<StatefulWidget> createState() => _NoteEditorState(note, uid);
}

/// [State] of [NoteEditor].
class _NoteEditorState extends State<NoteEditor>
    with CommandHandler
    implements NoteSyncContact {
  /// Create a state for [NoteEditor], with an optional [note] being edited,
  /// otherwise a new one will be created.
  final TextEditingController _titleTextController;
  final TextEditingController _contentTextController;

  /// The note in editing
  final Note _note;
  final int uid;

  /// The origin copy before editing
  final Note _originNote;
  NoteSyncPresenter _presenter;

  _NoteEditorState(Note note, int uid)
      : this._note = note ?? Note(userId: uid),
        _originNote = note?.copy() ?? Note(),
        this.uid = uid,
        this._titleTextController = TextEditingController(text: note?.title),
        this._contentTextController =
            TextEditingController(text: note?.content) {
    _presenter = new NoteSyncPresenter(this);
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final bloc = new NoteBloc();

  // Get our connection status from the provider
  var connectionStatus;

  BuildContext _ctx;

  /// If the note is modified.
  bool get _isDirty => _note != _originNote;

  @override
  void initState() {
    super.initState();
    _titleTextController
        .addListener(() => _note.title = _titleTextController.text);
    _contentTextController
        .addListener(() => _note.content = _contentTextController.text);
  }

  @override
  void dispose() {
    bloc.dispose();
    _titleTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }

  void onSyncSuccess(int noteId) {
    debugPrint('sync to node server successfully.');
    debugPrint('get note id is $noteId');
    _note
      ..noteId = noteId
      ..syncStatus = true
      ..saveToLocalDb();
  }

  void onSyncError(String errorText) {
    debugPrint(errorText);
    _note
      ..syncStatus = false
      ..saveToLocalDb();
  }

  void _unfocus(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      debugPrint('unfocus');
      currentFocus.unfocus();
    }
  }

  /// Callback before the user leave the editor.
  Future<bool> _onPop(
      BuildContext context, ConnectivityStatus connectionStatus) {
    if (_isDirty && (_note.id != null || _note.isNotEmpty)) {
      debugPrint('dirty..............');
      _note.modifiedAt = DateTime.now().millisecondsSinceEpoch;
      if (connectionStatus == ConnectivityStatus.Available) {
        _presenter.syncNote(_note, _note.id == null);
      } else {
        _note
          ..syncStatus = false
          ..saveToLocalDb();
      }
      debugPrint(
          'state is changed or not? ${_originNote.stateValue != _note.stateValue}');
      Navigator.pop(
          _ctx,
          NoteStateUpdateCommand(
              id: _note.id,
              uid: uid,
              from: _originNote.state,
              to: _note.state,
              streamFlag: _originNote.stateValue != _note.stateValue ||
                  _note.id == null,
              executeFlag: true));
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    return Hero(
        tag: 'NoteItem${_note.id}',
        child: Theme(
          data: Theme.of(context).copyWith(
            primaryColor: _note.color ?? kDefaultNoteColor,
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
                  elevation: 0,
                ),
            scaffoldBackgroundColor: _note.color ?? kDefaultNoteColor,
            bottomAppBarColor: _note.color ?? kDefaultNoteColor,
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            key: UniqueKey(),
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: _note.color ?? kDefaultNoteColor,
              systemNavigationBarColor: _note.color ?? kDefaultNoteColor,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: GestureDetector(
                onTap: () => _unfocus(context),
                child: Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    iconTheme: IconThemeData(color: Colors.black),
                    actions: _buildTopActions(context),
                    bottom: const PreferredSize(
                      preferredSize: Size(0, 24),
                      child: SizedBox(),
                    ),
                  ),
                  body: _buildBody(context),
                  bottomNavigationBar: _buildBottomAppBar(context),
                )),
          ),
        ));
  }

  Widget _buildBody(BuildContext context) => WillPopScope(
      onWillPop: () => _onPop(context, connectionStatus),
      child: DefaultTextStyle(
        style: kNoteTextLargeLight,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: _buildNoteDetail(),
          ),
        ),
      ));

  Widget _buildNoteDetail() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _titleTextController,
            style: kNoteTitleLight,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              counter: const SizedBox(),
            ),
            maxLines: null,
            maxLength: 1024,
            textCapitalization: TextCapitalization.sentences,
            readOnly: !_note.state.canEdit,
          ),
          TextField(
            controller: _contentTextController,
            style: kNoteTextLargeLight,
            decoration: const InputDecoration.collapsed(hintText: 'Note'),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            readOnly: !_note.state.canEdit,
          ),
        ],
      );

  List<Widget> _buildTopActions(BuildContext context) {
    final _pinned = _note.pinned;
    return [
      IconButton(
        icon: Icon(Icons.select_all),
        onPressed: () => showHintText('noteId is ${_note.noteId}'),
      ),
      if (_note.noteState != NoteState.deleted)
        IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(_pinned ? AppIcons.pin : AppIcons.pin_outlined),
            tooltip: _pinned ? 'Unpin' : 'Pin',
            onPressed: () {
              print('note pinned is $_pinned');
              final to = _pinned ? NoteState.unspecified : NoteState.pinned;
              final command = NoteStateUpdateCommand(
                  id: _note.id,
                  uid: uid,
                  from: _note.state,
                  to: to,
                  note: _note,
                  streamFlag: true,
                  executeFlag: true);
              _note
                ..noteState = to
                ..modifiedAt = DateTime.now().millisecondsSinceEpoch;
              if (connectionStatus == ConnectivityStatus.Available) {
                _presenter.syncNote(_note, _note.id == null);
              } else {
                _note
                  ..syncStatus = false
                  ..saveToLocalDb();
              }
              Navigator.pop(context, command);
            }),
      if (_note.id != null && _note.noteState < NoteState.archived)
        IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: const Icon(AppIcons.archive_outlined),
          tooltip: 'Archive',
          onPressed: () {
            _note
              ..noteState = NoteState.archived
              ..modifiedAt = DateTime.now().millisecondsSinceEpoch;
            if (connectionStatus == ConnectivityStatus.Available) {
              _presenter.syncNote(_note, _note.id == null);
            } else {
              _note
                ..syncStatus = false
                ..saveToLocalDb();
            }
            Navigator.pop(
                context,
                NoteStateUpdateCommand(
                    id: _note.id,
                    uid: uid,
                    from: _originNote.state,
                    to: _note.noteState,
                    note: _note,
                    streamFlag: true,
                    executeFlag: true));
          },
        ),
      if (_note.state == NoteState.archived)
        IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: const Icon(AppIcons.unarchive_outlined),
            tooltip: 'Unarchive',
            onPressed: () => _note.noteState = NoteState.unspecified)
    ];
  }

  Widget _buildBottomAppBar(BuildContext context) => BottomAppBar(
        child: Container(
          height: kBottomBarSize,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(AppIcons.add_box),
                color: kIconTintLight,
                onPressed: _note.state.canEdit ? () {} : null,
              ),
              Text('Edited ${_note.strLastModifiedSim}'),
              IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(Icons.more_vert),
                  color: kIconTintLight,
                  onPressed: () => _showNoteBottomSheet(context)),
            ],
          ),
        ),
      );

  void _showNoteBottomSheet(BuildContext context) async {
    _unfocus(context);
    final command = await showModalBottomSheet<NoteCommand>(
        context: _scaffoldKey.currentContext,
        backgroundColor: _note.color ?? kDefaultNoteColor,
        builder: (context) => MultiProvider(
              providers: [
                ListenableProvider<Note>.value(
                  key: UniqueKey(),
                  value: _note,
                ),
                ListenableProvider<NoteTagProvider>.value(
                    key: UniqueKey(), value: NoteTagProvider())
              ],
              child: Consumer2<Note, NoteTagProvider>(
                  builder: (context, note, noteTag, child) => Container(
                      color: note.color ?? kDefaultNoteColor,
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          NoteActions(note, bloc),
                          if (note.state.canEdit) const SizedBox(height: 16),
                          if (note.state.canEdit) LinearColorPicker(note),
                          const SizedBox(height: 12),
                        ],
                      ))),
            ));

    if (command != null) {
      if (command.dismiss) {
        Navigator.pop(context, command);
      } else if (command.isExecute) {
        print('command 不是空的');
        processNoteCommand(_scaffoldKey.currentState, command);
      }
    }
  }
}
