import 'package:flutter/material.dart';
import 'package:keep/utils/notes_service.dart';
import 'package:keep/settings/icons.dart';
import 'package:keep/BLoC/note_bloc.dart';
import 'package:keep/models/note.dart';
// import 'package:keep/services.dart';
import 'package:keep/settings/styles.dart';
import 'package:keep/widget/note_tag.dart';
import 'package:keep/utils/utils_class.dart' show SelTagReceiver;
import 'package:keep/data/provider/noteTag_provider.dart';

/// Provide actions for a single [Note], used in a [BottomSheet].
class NoteActions extends StatelessWidget {
  final Note note;
  final NoteBloc bloc;
  NoteActions(this.note, this.bloc);

  final textStyle = TextStyle(
    color: kHintTextColorLight,
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    final state = note.noteState;
    final id = note?.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        id != null && state != NoteState.archived
            ? ListTile(
                dense: true,
                leading: const Icon(AppIcons.archive_outlined),
                title: Text('Archive', style: textStyle),
                onTap: () {
                  final command = NoteStateUpdateCommand(
                      id: note.id,
                      uid: note.userId,
                      from: note.state,
                      to: NoteState.archived,
                      note: note,
                      dismiss: true,
                      streamFlag: true,
                      executeFlag: true);
                  // note.updateWith(state: NoteState.archived);
                  note
                    ..noteState = NoteState.archived
                    ..syncStatus = false
                    ..modifiedAt = DateTime.now().millisecondsSinceEpoch
                    ..saveToLocalDb();
                  Navigator.pop(context, command);
                })
            : Container(),
        state == NoteState.archived
            ? ListTile(
                dense: true,
                leading: const Icon(AppIcons.unarchive_outlined),
                title: Text('Unarchive', style: textStyle),
                onTap: () {
                  final command = NoteStateUpdateCommand(
                      id: note.id,
                      uid: note.userId,
                      from: note.state,
                      to: NoteState.unspecified,
                      dismiss: true,
                      streamFlag: true,
                      executeFlag: true);
                  // note.updateWith(state: NoteState.unspecified);
                  note
                    ..noteState = NoteState.unspecified
                    ..syncStatus = false
                    ..modifiedAt = DateTime.now().millisecondsSinceEpoch
                    ..saveToLocalDb();
                  Navigator.pop(context, command);
                })
            : Container(),
        id != null
            ? ListTile(
                dense: true,
                leading: const Icon(AppIcons.delete_outline),
                title: Text('Delete', style: textStyle),
                onTap: () {
                  if (state == NoteState.deleted) {
                    note.delete();
                    // 这里还需要同步到server
                    Navigator.pop(
                        context,
                        NoteStateUpdateCommand(
                            id: note.id,
                            uid: note.userId,
                            from: note.state,
                            to: NoteState.deleted,
                            note: note,
                            dismiss: true,
                            streamFlag: true,
                            executeFlag: false));
                  } else {
                    // note.updateWith(state: NoteState.deleted);
                    final command = NoteStateUpdateCommand(
                        id: note.id,
                        uid: note.userId,
                        from: note.state,
                        to: NoteState.deleted,
                        note: note,
                        dismiss: true,
                        streamFlag: true,
                        executeFlag: true);
                    note
                      ..noteState = NoteState.deleted
                      ..modifiedAt = DateTime.now().millisecondsSinceEpoch
                      ..syncStatus = false
                      ..saveToLocalDb();
                    Navigator.pop(context, command);
                  }
                })
            : Container(),
        state == NoteState.deleted
            ? ListTile(
                dense: true,
                leading: const Icon(Icons.restore),
                title: Text('Restore', style: textStyle),
                onTap: () {
                  final command = NoteStateUpdateCommand(
                      id: note.id,
                      uid: note.userId,
                      from: note.state,
                      to: NoteState.unspecified,
                      note: note,
                      dismiss: true,
                      streamFlag: true,
                      executeFlag: true);
                  // note.updateWith(state: NoteState.unspecified);
                  note
                    ..noteState = NoteState.unspecified
                    ..modifiedAt = DateTime.now().millisecondsSinceEpoch
                    ..syncStatus = false
                    ..saveToLocalDb();
                  Navigator.pop(context, command);
                })
            : Container(),
        id != null
            ? ListTile(
                dense: true,
                leading: const Icon(AppIcons.copy),
                title: Text('Make a Copy', style: textStyle),
                onTap: () {})
            : Container(),
        ListTile(
          dense: true,
          leading: const Icon(AppIcons.share_outlined),
          title: Text('Send', style: textStyle),
        ),
        ListTile(
            dense: true,
            leading: const Icon(AppIcons.label),
            title: Text('Labels', style: textStyle),
            onTap: () => addLabel(context, note).then((selTags) {
                  if (selTags.length > 0) {
                    note.updateWith(tag: selTags.join(' '));
                    NoteTagProvider().addTag(selTags);
                  }
                })),
      ],
    );
  }

  addLabel(BuildContext context, Note note) => Navigator.push<SelTagReceiver>(
              context,
              MaterialPageRoute(builder: (context) => NoteTagPage(note)))
          .then((data) {
        List<String> selTags = <String>[];
        if (data == null || data.stream['tags'].isEmpty)
          print('empty op');
        else if (data.stream['tags'].isNotEmpty)
          selTags.addAll(data.stream['tags']);
        return selTags;
      });
}
