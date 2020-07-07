import 'package:collection_ext/iterables.dart';
import 'package:flutter/material.dart';
import 'package:keep/models/note.dart';
import 'package:keep/data/sputil.dart';
import 'package:provider/provider.dart';

import 'note_item.dart';

/// ListView for notes
class NotesList extends StatefulWidget {
  final List<Note> notes;
  final void Function(Note) onTap;
  final int stateId;

  const NotesList({
    Key key,
    @required this.notes,
    @required this.stateId,
    this.onTap,
  }) : super(key: key);

  static NotesList create({
    Key key,
    @required List<Note> notes,
    @required int stateId,
    void Function(Note) onTap,
  }) =>
      NotesList(
        key: key,
        notes: notes,
        stateId: stateId,
        onTap: onTap,
      );

  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  Note _movingValue;
  List<int> _noteIdList = <int>[];

  @override
  void initState() {
    super.initState();
    SpUtil.getStringList('idList').forEach((val) {
      _noteIdList.add(int.parse(val));
    });
  }

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverList(
          delegate: SliverChildListDelegate(
            widget.notes
                .flatMapIndexed((i, note) => <Widget>[
                      ChangeNotifierProvider<Note>.value(
                          key: UniqueKey(),
                          value: note,
                          builder: (context, child) => Consumer<Note>(
                              builder: (context, note, child) => InkWell(
                                    onTap: () => widget.onTap?.call(note),
                                    child: draggableItem(note),
                                  ))),
                      i < widget.notes.length - 1
                          ? const SizedBox(height: 10)
                          : Container(),
                    ])
                .asList(),
          ),
        ),
      );

  // 生成可拖动的item
  Widget draggableItem(value) {
    return LongPressDraggable(
      data: value,
      child: DragTarget(
        builder: (context, candidateData, rejectedData) {
          return baseItem(context, value, longPressFlag: false);
        },
        onWillAccept: (moveData) {
          print('=== onWillAccept: $moveData ==> $value');
          var accept = moveData != null;
          if (accept) {
            exchangeItem(moveData, value, false);
          }
          return accept;
        },
        onAccept: (moveData) {
          print('=== onAccept: $moveData ==> $value');
          exchangeItem(moveData, value, true);
        },
        onLeave: (moveData) {
          print('=== onLeave: $moveData ==> $value');
        },
      ),
      feedback: Material(
          child: Container(
              width: MediaQuery.of(context).size.width - 20.0,
              // height: 225.0,
              color: Colors.transparent,
              child: NoteItem(note: value, longPressFlag: true))),
      childWhenDragging: Container(
          width: MediaQuery.of(context).size.width - 20.0,
          // height: 225.0,
          color: Colors.transparent,
          // alignment: Alignment.center,
          foregroundDecoration: BoxDecoration(color: Colors.white30),
          child: baseItem(context, value)),
      onDragStarted: () {
        print('=== onDragStarted');
        setState(() {
          _movingValue = value; //记录开始拖拽的数据
        });
      },
      onDraggableCanceled: (Velocity velocity, Offset offset) {
        print('=== onDraggableCanceled');
        setState(() {
          _movingValue = null; //清空标记进行重绘
        });
      },
      onDragCompleted: () {
        print('=== onDragCompleted');
      },
    );
  }

  // 基础展示的item 此处设置width,height对GridView 无效，主要是偷懒给feedback用
  Widget baseItem(context, value, {bool longPressFlag = false}) {
    if (value == _movingValue) {
      return Container(
        height: 96,
      );
    }
    return NoteItem(note: value, longPressFlag: longPressFlag);
  }

  // 重新排序
  void exchangeItem(moveData, toData, onAccept) {
    setState(() {
      var toIndex = widget.notes.indexOf(toData);
      widget.notes.remove(moveData);
      widget.notes.insert(toIndex, moveData);
      if (onAccept) {
        _movingValue = null;
        // widget.notes[toIndex].updateWith()
      }
    });
  }
}
