import 'package:flutter/material.dart';
import 'package:keep/BLoC/note_bloc.dart';
import 'package:keep/models/note.dart';
import 'package:keep/utils/event_util.dart';

/// An undoable action to a [Note].
@immutable
abstract class NoteCommand {
  final int id;
  final int uid;

  /// Whether this command should dismiss the current screen.
  final bool dismiss;

  /// whether to reload stream
  final bool streamFlag;

  /// whether to execute update the state
  final bool executeFlag;

  /// Defines an undoable action to a note, provides the note [id], and current user [uid].
  const NoteCommand(
      {@required this.id,
      @required this.uid,
      this.dismiss = false,
      this.streamFlag = false,
      this.executeFlag = true});

  /// Returns `true` if this command is undoable.
  bool get isUndoable => true;

  /// Returns `true` if there needs to reload note stream
  bool get updateStream => (streamFlag == true);

  /// Return `true` if there needs to update note state
  bool get isExecute => (executeFlag == true);

  /// Returns message about the result of the action.
  String get message => '';

  NoteState get toState => NoteState.unspecified;

  /// Executes this command.
  Future<void> execute();

  /// Undo this command.
  Future<void> revert();
}

/// A [NoteCommand] to update state of a [Note].
class NoteStateUpdateCommand extends NoteCommand {
  final NoteState from;
  final NoteState to;
  final Note note;

  /// Create a [NoteCommand] to update state of a note [from] the current state [to] another.
  NoteStateUpdateCommand(
      {@required int id,
      @required int uid,
      @required this.from,
      @required this.to,
      this.note,
      bool dismiss = false,
      bool streamFlag = false,
      bool executeFlag = true})
      : super(
            id: id,
            uid: uid,
            dismiss: dismiss,
            streamFlag: streamFlag,
            executeFlag: executeFlag);

  @override
  String get message {
    switch (to) {
      case NoteState.deleted:
        return 'Note moved to trash';
      case NoteState.archived:
        return 'Note archived';
      case NoteState.pinned:
        return from == NoteState.archived
            ? 'Note pinned and unarchived' // pin an archived note
            : '';
      default:
        switch (from) {
          case NoteState.archived:
            return 'Note unarchived';
          case NoteState.deleted:
            return 'Note restored';
          default:
            return '';
        }
    }
  }

  NoteState get toState => to;

  @override
  Future<void> execute() => null;

  @override
  Future<void> revert() => updateNoteState(note, from);
}

/// Mixin helps handle a [NoteCommand].
mixin CommandHandler<T extends StatefulWidget> on State<T> {
  bool processStreamLoad(NoteCommand command) {
    return command != null ? command.updateStream : false;
  }

  /// Processes the given [command].
  Future<void> processNoteCommand(
      ScaffoldState scaffoldState, NoteCommand command) async {
    if (command == null) {
      debugPrint('command is null..................');
    } else if (command.isExecute) {
      debugPrint('command is not null...............');
      await command.execute();
      final msg = command.message;
      // print(command.isUndoable);
      if (mounted && msg?.isNotEmpty == true && command.isUndoable) {
        scaffoldState?.showSnackBar(SnackBar(
          content: Text(msg),
          action:
              SnackBarAction(label: 'Undo', onPressed: () => command.revert()),
        ));
      }
    }
  }
}

/// Add FireStore related methods to the [Note] model.
extension NoteStore on Note {
  static final bloc = NoteBloc();
  // static final _api = new RestDatasource();

  /// Save this note in FireStore.
  ///
  /// If this's a new note, a FireStore document will be created automatically.
  Future<dynamic> saveToLocalDb() async =>
      id == null ? bloc.addNote(this) : bloc.updateNote(this);

  // Future<dynamic> saveToNodeServer(int userId, {int noteId}) async =>
  //     id == null ? _api.createNote(this, userId, noteId) : _api.updateNote(this, userId, id);

  Future<dynamic> delete() async => bloc.deleteNoteById(this.id);

  /// Update this note to the given [state].
  Future<void> updateState(NoteState state) async {
    this.noteState = state;
    this.saveToLocalDb();
  }

  dispose() {
    bloc.dispose();
  }
}

/// Update a note to the [state], using information in the [command].
updateNoteState(Note note, NoteState state) {
  note
    ..noteState = state
    ..saveToLocalDb();
  bus.emit('note_page_update', true);
}
