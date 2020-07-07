import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:keep/models/note.dart';
import 'package:keep/data/provider/noteTag_provider.dart';
import 'package:keep/settings/icons.dart';
import 'package:keep/widget/over_scroll.dart';
import 'package:keep/utils/tools_function.dart' show showHintText;
import 'package:keep/utils/utils_class.dart' show SelTagReceiver;

class NoteTagPage extends StatefulWidget {
  final Note note;
  NoteTagPage(this.note);

  @override
  _NoteTagPageState createState() => _NoteTagPageState();
}

class _NoteTagPageState extends State<NoteTagPage> {
  final TextEditingController textController = new TextEditingController();

  // control variable
  List<bool> status = <bool>[];
  ValueNotifier<List<String>> _selTags;
  List<String> tags = NoteTagProvider().tags;
  // String preText;

  @override
  void initState() {
    super.initState();
    _selTags = ValueNotifier<List<String>>(
        widget.note.tag.isNotEmpty ? widget.note.tag.split(' ') : []);
    textController.addListener(textListener);

    // used to judge check box
    tags.forEach((val) {
      status.add(false);
    });
    _selTags.value.forEach((val) {
      int idx = tags.indexOf(val);
      status[idx] = true;
    });

    // print(_selTags.value);
    // print(status);
  }

  @override
  void dispose() {
    textController.removeListener(textListener);
    textController.dispose();
    _selTags.dispose();
    super.dispose();
  }

  bool checkSelection(String tag) => _selTags.value.indexOf(tag) == -1;

  void textListener() {
    if (textController.text.isNotEmpty &&
        textController.text.endsWith(' ') &&
        !textController.text.startsWith(' ')) {
      String tag = textController.text.trim();
      if (checkSelection(tag)){
        _selTags.value = List.from(_selTags.value)..add(tag);
        int idx = tags.indexOf(tag);
        if(idx > -1)
          setState(() => status[idx] = true);
      }
        // preText = textController.text;
      // else
      //   showHintText('There already have');
      // 这里会监测两次，不知道怎么回事
      textController.text = '';
      textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('reload whole page');
    return Material(
        child: SafeArea(
            child: Column(children: [
      buildHeader(context),
      ValueListenableBuilder<List<String>>(
          valueListenable: _selTags,
          builder: (BuildContext context, List<String> selTags, Widget child) =>
            buildSelTagSection(selTags)
          ),
      buildBottomLine(),
      buildTagList(context)
    ])));
  }

  Widget buildHeader(BuildContext context) {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(children: <Widget>[
          Flexible(
              flex: 1,
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context))),
          Flexible(
              flex: 6,
              child: Container(
                  // width: MediaQuery.of(context).size.width * 0.4,
                  height: 36.0,
                  child: new TextFormField(
                    enableInteractiveSelection: true,
                    controller: textController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Add new label',
                      hintStyle: TextStyle(
                          fontSize: 16.0, color: Colors.black.withAlpha(164)),
                      contentPadding:
                          EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                    ),
                  ))),
          Container(
              child: IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              String tag = textController.text;
              if (tag.isNotEmpty && !tag.startsWith(' ')) {
                textController.clear();
                List<String> selection = List<String>.from(_selTags.value)
                  ..add(tag);
                Navigator.pop(context, SelTagReceiver({'tags': selection}));
              } else if (tag.isEmpty && _selTags.value.length > 0) 
                Navigator.pop(
                    context, SelTagReceiver({'tags': _selTags.value}));
              else
                showHintText('Still not add anything');
            },
          ))
        ]));
  }

  Widget buildSelTagSection(List<String> selTags) {
    // print('selLength: ${selTags[0].length}');
    print('reload this row section');
    return Container(
        height: 50.0,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
        child: selTags.length > 0
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 36.0),
                child: ScrollConfiguration(
                    behavior: OverScrollBehavior(),
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: selTags.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                int idx = tags.indexOf(selTags[index]);
                                List<String> selection =
                                    List.from(_selTags.value);
                                selection.removeAt(index);
                                _selTags.value = selection;
                                if (idx == -1)
                                  debugPrint('new one');
                                else
                                  setState(() => status[idx] = false);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: widget.note.color,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border: Border.all(
                                          color: widget.note.color
                                              .withGreen(164))),
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Center(
                                      child: Text(
                                    selTags[index],
                                    style: TextStyle(color: Colors.black),
                                  ))));
                        })))
            : Align(
                alignment: Alignment.centerLeft,
                child: Text('Add Some Tag...',
                    style: TextStyle(color: Colors.black54, fontSize: 16.0))));
  }

  Widget buildBottomLine() {
    return Container(
        height: 2,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 45.0,
                  offset: Offset(0.0, 0.75))
            ],
            border: Border(
                bottom: BorderSide(width: 1.2, color: Color(0xffe5e5e5)))));
  }

  Widget buildTagList(BuildContext context) {
    print('reload the whole list');
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: tags.length,
        itemBuilder: (BuildContext context, int index) {
          return new ListTile(
            enabled: false,
            leading: Icon(AppIcons.label),
            title: Text(tags[index], style: TextStyle(color: Colors.black54)),
            trailing: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(status[index]
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                onPressed: () {
                  if (status[index]) {
                    List<String> selection = List.from(_selTags.value);
                    selection.remove(tags[index]);
                    _selTags.value = selection;
                    setState(() => status[index] = false);
                  } else {
                    _selTags.value = List.from(_selTags.value)
                      ..add(tags[index]);
                    setState(() => status[index] = true);
                  }
                }),
          );
        });
  }
}
