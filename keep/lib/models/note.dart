import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keep/data/provider/user_provider.dart';
// import 'package:keep/service/note_presenter.dart';

/// Data model of a note.
class Note extends ChangeNotifier {
  final int id;
  final int userId;
  int noteId;
  String title;
  String content;
  String tag;
  Color color;
  NoteState state;
  final int createdAt;
  int modifiedAt;
  bool isSync;

  /// Instantiates a [Note].
  Note({
    this.id,
    this.userId,
    this.noteId,
    this.title,
    this.content,
    this.state,
    bool isSync,
    Color color,
    String tag,
    int createdAt,
    int modifiedAt,
  })  : this.isSync = isSync ?? true,
        this.tag = tag ?? '',
        this.color = color ?? Colors.white,
        this.createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        this.modifiedAt = modifiedAt ?? DateTime.now().millisecondsSinceEpoch;

  @override
  String toString() {
    return '{ ${this.content} }';
  }

  factory Note.fromDatabaseJson(Map<String, dynamic> data) => Note(
      id: data['id'],
      noteId: data['note_id'],
      userId: data['user_id'],
      title: data['title'],
      content: data['content'],
      isSync: data['is_sync'] == 1,
      tag: data['tag'] ?? '',
      color: Color(
          int.parse(data['color'], radix: 16)), // color hexString to Color
      state: NoteState.values[data['state'] ?? 0], // 默认是unspecified
      createdAt: data['created_at'],
      modifiedAt: data['modified_at']);

  Map<String, dynamic> toDatabaseJson() => {
        "note_id": this.noteId,
        "user_id": this.userId ?? UserProvider.getUserId(),
        "title": this.title,
        "content": this.content,
        "is_sync": this.isSync ? 1 : 0,
        "tag": this.tag ?? '',
        "color": this.color != null
            ? this.color.value.toRadixString(16)
            : Colors.white.value.toRadixString(16), // Color to String
        "state": this.state != null ? this.state.index : 0,
        "created_at": this.createdAt,
        "modified_at": this.modifiedAt
      };

  static Note fromMap(Map data) => Note(
      noteId: data['note_id'],
      userId: data['user_id'],
      title: data['title'],
      content: data['content'],
      isSync: data['is_sync'] == 1,
      tag: data['tag'] ?? '',
      color: Color(
          int.parse(data['color'], radix: 16)), // color hexString to Color
      state: NoteState.values[data['state'] ?? 0], // 默认是unspecified
      createdAt: data['created_at'],
      modifiedAt: data['modified_at']);

  // /// Transforms the Firestore query [snapshot] into a list of [Note] instances.
  static List<Note> fromQuery(decodedJson) => decodedJson != null
      ? (decodedJson.map((obj) => Note.fromMap(obj)).toList().cast<Note>())
      : [];

  /// Whether this note is pinned
  bool get pinned => state == NoteState.pinned;
  NoteState get noteState => state ?? NoteState.unspecified;
  bool get syncStatus => this.isSync;
  String get tags => this.tag;

  /// Returns an numeric form of the state
  int get stateValue => (state ?? NoteState.unspecified).index;
  bool get isNotEmpty =>
      title?.isNotEmpty == true || content?.isNotEmpty == true;

  /// Formatted last modified time
  String get strLastModifiedSim =>
      DateFormat.MMMd().format(DateTime.fromMicrosecondsSinceEpoch(modifiedAt));

  String get strLastModified => DateFormat('yyyy/MM/dd HH:mm')
      .format(DateTime.fromMillisecondsSinceEpoch(modifiedAt));

  set tags(String value) {
    this.tag = value;
    notifyListeners();
  }

  set syncStatus(bool value) {
    this.isSync = value;
    notifyListeners();
  }

  set noteState(NoteState value) {
    this.state = value;
    notifyListeners();
  }

  /// Update this note with another one.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modifiedAt` will be updated to `DateTime.now()`, otherwise, the value of `modifiedAt`
  /// will also be copied from [other].
  void update(Note other, {bool updateTimestamp = true}) {
    title = other.title;
    content = other.content;
    tag = other.tag;
    color = other.color;
    state = NoteState.values[other.state.index];

    if (updateTimestamp || other.modifiedAt == null) {
      modifiedAt = DateTime.now().millisecondsSinceEpoch;
    } else {
      modifiedAt = other.modifiedAt;
    }
    notifyListeners();
  }

  /// Update this note with specified properties.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modifiedAt` will be updated to `DateTime.now()`.
  Note updateWith({
    String title,
    String content,
    String tag,
    Color color,
    NoteState state,
    bool updateTimestamp = true,
  }) {
    if (title != null) this.title = title;
    if (content != null) this.content = content;
    if (tag != null) this.tag = tag;
    if (color != null) this.color = color;
    if (state != null) this.state = state;
    if (updateTimestamp) modifiedAt = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return this;
  }

  updatePinned() {
    if (this.stateValue == NoteState.pinned.index)
      this.state = NoteState.unspecified;
    else
      this.state = NoteState.pinned;
    notifyListeners();
  }

  /// Serializes this note into a JSON object.
  Map<String, dynamic> toJson() {
    print('toJson now this note id is $noteId');
    return {
      'note_id': noteId,
      'user_id': userId,
      'title': title,
      'content': content,
      'tag': tag,
      'color': color.value.toRadixString(16),
      'state': stateValue,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      'modified_at': modifiedAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Make a copy of this note.
  ///
  /// If [updateTimestamp] is `true`, the defaults is `false`,
  /// timestamps both of `createdAt` & `modifiedAt` will be updated to `DateTime.now()`,
  /// or otherwise be identical with this note.
  Note copy({bool updateTimestamp = false}) => Note(
        id: id,
        createdAt:
            (updateTimestamp || createdAt == null) ? DateTime.now() : createdAt,
      )..update(this, updateTimestamp: updateTimestamp);

  @override
  bool operator ==(other) =>
      other is Note &&
      (other.id ?? '') == (id ?? '') &&
      (other.title ?? '') == (title ?? '') &&
      (other.content ?? '') == (content ?? '') &&
      (other.tag ?? '') == (tag ?? '') &&
      other.stateValue == stateValue &&
      (other.color ?? 0) == (color ?? 0);

  @override
  int get hashCode => id?.hashCode ?? super.hashCode;
}

/// State enum for a note.
enum NoteState {
  unspecified,
  pinned,
  archived,
  deleted,
}

/// Add properties/methods to [NoteState]
extension NoteStateX on NoteState {
  /// Checks if it's allowed to create a new note in this state.
  bool get canCreate => this <= NoteState.pinned;

  /// Checks if a note in this state can edit (modify / copy).
  bool get canEdit => this < NoteState.deleted;

  bool operator <(NoteState other) => (this?.index ?? 0) < (other?.index ?? 0);
  bool operator <=(NoteState other) =>
      (this?.index ?? 0) <= (other?.index ?? 0);

  /// Message describes the state transition.
  String get message {
    switch (this) {
      case NoteState.archived:
        return 'Note archived';
      case NoteState.deleted:
        return 'Note moved to trash';
      default:
        return '';
    }
  }

  /// Label of the result-set filtered via this state.
  String get filterName {
    switch (this) {
      case NoteState.archived:
        return 'Archive';
      case NoteState.deleted:
        return 'Trash';
      default:
        return '';
    }
  }

  /// Short message explains an empty result-set filtered via this state.
  String get emptyResultMessage {
    switch (this) {
      case NoteState.archived:
        return 'Archived notes appear here';
      case NoteState.deleted:
        return 'Notes in trash appear here';
      default:
        return 'Notes you add appear here';
    }
  }
}
