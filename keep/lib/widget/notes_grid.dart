import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keep/models/note.dart';
import 'package:provider/provider.dart';
import 'note_item.dart';

/// Grid view of [Note]s.
class NotesGrid extends StatefulWidget {
  final List<Note> notes;
  final void Function(Note) onTap;
  final int stateId;

  const NotesGrid({
    Key key,
    @required this.notes,
    @required this.stateId,
    this.onTap,
  }) : super(key: key);

  static NotesGrid create({
    Key key,
    @required List<Note> notes,
    @required int stateId,
    void Function(Note) onTap,
  }) =>
      NotesGrid(
        key: key,
        notes: notes,
        stateId: stateId,
        onTap: onTap,
      );

  @override
  _NotesGridState createState() => _NotesGridState();
}

class _NotesGridState extends State<NotesGrid> {
  Note _movingValue;
  // List<int> _idxList = <int>[]; // [0, 1] list of nowIndex

  // List<String> _idxChangeStrList; // ['2-0', '1-1'] list of '$nowIndex-$toIndex'
  // // Map<int, int> _idxMapToMove = {}; // {2: 0, 1: 1} map from _idxChangeStrList

  // Map<int, int> _noteIdMapIdx = {}; // noteId : index
  // Map<int, int> _idxMapNoteId = {}; // index : noteId

  // @override
  // void initState() {
  //   super.initState();
  //   _idxChangeStrList =
  //       SpUtil.getStringList('idxChangeStrList${widget.stateId}') ?? <String>[];
  //   for (int i = 0; i < widget.notes.length; i++) {
  //     _idxList.add(i);
  //     _noteIdMapIdx[widget.notes[i].id] = i;
  //     _idxMapNoteId[i] = widget.notes[i].id;
  //   }
  //   bus.on('addId', (noteId) {
  //     _idxList.add(_idxList.length);
  //     _noteIdMapIdx[noteId] = _idxList.length;
  //     _idxMapNoteId[_idxList.length] = noteId;
  //   });

  //   int minEdge, maxEdge, iaddValue;
  //   _idxChangeStrList.forEach((val) {
  //     List<String> idMap = val.split('-');
  //     int nowIdx = int.parse(idMap[0]);
  //     int toIdx = int.parse(idMap[1]);
  //     int _idx = _idxList[nowIdx];
  //     _idxList.removeAt(nowIdx);
  //     _idxList.insert(toIdx, _idx);
  //     _noteIdMapIdx[_idxMapNoteId[nowIdx]] = toIdx;
  //     // 默认向低位移动，受影响位置index + 1
  //     iaddValue = 1;
  //     minEdge = toIdx;
  //     maxEdge = nowIdx;
  //     if (minEdge > maxEdge) {
  //       iaddValue = -1;
  //       minEdge = nowIdx;
  //       maxEdge = toIdx;
  //     }
  //     // 调整受移动影响的位置
  //     for (int i = minEdge; i < maxEdge; i++) {
  //       _noteIdMapIdx[_idxMapNoteId[i]] += iaddValue;
  //     }
  //     _noteIdMapIdx.forEach((noteId, nowId) {
  //       _idxMapNoteId[nowId] = noteId;
  //     });
  //   });
  //   print(_idxChangeStrList);
  //   print(_idxList);
  //   // print(_noteIdMapIdx);
  //   // update _noteIdMapIdx
  //   _noteIdMapIdx.forEach((noteId, nowIdx) {
  //     _idxMapNoteId[nowIdx] = noteId;
  //   });
  // }

  // @override
  // void dispose() {
  //   bus.off('addId');
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverStaggeredGrid.countBuilder(
        itemCount: widget.notes.length,
        itemBuilder: (context, index) =>
            _noteItem(context, widget.notes[index]),
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
      ));

  Widget _noteItem(BuildContext context, Note note,
          {bool longPressFlag = false}) =>
      ChangeNotifierProvider<Note>.value(
          key: UniqueKey(),
          value: note,
          builder: (context, child) => Consumer<Note>(
              builder: (context, note, child) => Material(
                      child: InkWell(
                    // highlightColor: Colors.grey,
                    onTap: () => widget.onTap?.call(note),
                    child: draggableItem(note),
                  ))));

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
              width: (MediaQuery.of(context).size.width - 30.0) * 0.5,
              // height: 225.0,
              color: Colors.transparent,
              child: NoteItem(note: value, longPressFlag: true))),
      childWhenDragging: Container(
          width: (MediaQuery.of(context).size.width - 30.0) * 0.5,
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
      return Container(height: 230);
    }
    return NoteItem(note: value, longPressFlag: longPressFlag);
  }

  // 重新排序
  void exchangeItem(moveData, toData, onAccept) {
    // List<String> idxChangeStrList = <String>[];
    setState(() {
      var toIndex = widget.notes.indexOf(toData);
      // print('toIndex: $toIndex');
      widget.notes.remove(moveData);
      widget.notes.insert(toIndex, moveData);
      if (onAccept) {
        _movingValue = null;

        // // save the change str of moving
        // _idxChangeStrList.forEach((val) {
        //   idxChangeStrList.add(val);
        // });
        // idxChangeStrList.add(
        //     _noteIdMapIdx[moveData.id].toString() + '-' + toIndex.toString());

        // // 默认向低位移动
        // int iaddValue = 1;
        // int maxEdge = _noteIdMapIdx[moveData.id];
        // int minEdge = toIndex;
        // if (minEdge > maxEdge) {
        //   iaddValue = -1;
        //   minEdge = _noteIdMapIdx[moveData.id];
        //   maxEdge = toIndex;
        // }

        // // print('_idxMapNoteID:');
        // // print(_idxMapNoteId);
        // // print('_noteIdMapIdx:');
        // // print(_noteIdMapIdx);
        // // _idxMapNoteId.remove(_noteIdMapIdx[moveData.id]);
        // // _idxMapNoteId[toIndex] = moveData.id;
        // _noteIdMapIdx[moveData.id] = toIndex;

        // // print('minValue: $minEdge');
        // // print('maxValue: $maxEdge');
        // for (int i = minEdge; i < maxEdge; i++) {
        //   _noteIdMapIdx[_idxMapNoteId[i]] += iaddValue;
        // }
        // _noteIdMapIdx.forEach((noteId, nowId) {
        //   _idxMapNoteId[nowId] = noteId;
        // });
        // // print('==========================>changeStrList');
        // // print(idxChangeStrList);
        // // print(_noteIdMapIdx);
        // SpUtil.putStringList(
        //     'idxChangeStrList${widget.stateId}', idxChangeStrList);
        // _idxList = [];
        // _idxChangeStrList = idxChangeStrList;
      }
    });
  }
}
