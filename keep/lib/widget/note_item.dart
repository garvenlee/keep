import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:keep/models/note.dart';
import 'package:keep/settings/styles.dart';

/// A single item (preview of a Note) in the Notes list.
class NoteItem extends StatelessWidget {
  const NoteItem({Key key, this.note, this.longPressFlag}) : super(key: key);

  final Note note;
  final bool longPressFlag;

  @override
  Widget build(BuildContext context) {
    // print(note.content);
    return Hero(
      tag: 'NoteItem${note.id ?? 0}',
      child: DefaultTextStyle(
        style: kNoteTextLight,
        child: Container(
          // height: 225.0,
          decoration: BoxDecoration(
            color: note.color,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: this.longPressFlag
                ? Border.all(color: Colors.black, width: 2.0)
                : (note.color.value.toRadixString(16) == 'ffffffff'
                    ? Border.all(color: kBorderColorLight)
                    : null),
            boxShadow: [
              if (this.longPressFlag)
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  // offset: Offset(2.0, 2.0), // shadow direction: bottom right
                )
            ],
          ),
          padding:
              const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 5.0),
          child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  note.title?.isNotEmpty == true
                      ? Text(note.title,
                          style: kCardTitleLight,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false)
                      : Container(),
                  note.title?.isNotEmpty == true
                      ? const SizedBox(height: 2)
                      : Container(),
                  Flexible(
                    flex: 1,
                    child: Container(
                        // padding: EdgeInsets.only(left: 12.0),
                        alignment: Alignment.centerRight,
                        child: Text(note.strLastModified,
                            style: TextStyle(fontSize: 10.0))),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Flexible(
                    flex: 6,
                    child: Text(
                      note.content ?? '',
                      maxLines: 6,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ), // wrapping using a Flexible to avoid overflow
                  ),
                  Flexible(
                      flex: 1,
                      child: Container(
                        height: 20.0,
                      )),
                  if (note.tag.length > 0)
                    buildHorizontalTag(context, note.tag),
                ],
              ),
        ),
      ),
    );
  }

  Widget buildHorizontalTag(BuildContext context, String tags) {
    List<String> tagList = tags.split(' ');
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
                height: 20,
                child: new ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: tagList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        margin: EdgeInsets.only(right: 5.0),
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            color: note.color,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border:
                                Border.all(color: note.color.withGreen(164))),
                        child: Center(child: Text(tagList[index],
                            style: TextStyle(fontSize: 12.0))));
                  },
                )));
  }
}
