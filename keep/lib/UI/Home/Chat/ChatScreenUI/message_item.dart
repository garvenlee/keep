import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';
import 'package:keep/utils/event_util.dart';
import 'package:keep/global/global_tool.dart';

class ChatItemWidget extends StatefulWidget {
  final id;
  final bool isSelf;
  final String text;
  final String username;
  final bool timestampFlag;
  final int timestamp;
  final bool success;
  final AnimationController animationController;

  ChatItemWidget({
    this.id,
    this.username,
    this.text,
    this.animationController,
    this.isSelf,
    this.timestampFlag,
    this.timestamp,
    this.success,
  });

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  var _tapPosition;
  Widget buildUsername() {
    return Container(
        // margin: EdgeInsets.only(bottom: 5.0),
        child: Text(capitalize(widget.username),
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)));
  }

  Widget buildErrMsgHeader() {
    if (widget.success) {
      return Container();
    } else {
      return Container(
          // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 8.0,
              child: new Text('!',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))));
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Widget buildTextSection(BuildContext context) {
    if (widget.isSelf) {
      return GestureDetector(
          onTapDown: _storePosition,
          onLongPress: () {
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject();
            showMenu(
                context: context,
                position: RelativeRect.fromRect(
                    _tapPosition & Size(40, 40), // smaller rect, the touch area
                    Offset.zero & overlay.size // Bigger rect, the entire screen
                    ),
                items: <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      value: 'value01',
                      child: InkWell(onTap: () {}, child: new Text('Copy'))),
                  !widget.success
                      ? new PopupMenuItem<String>(
                          value: 'value02',
                          child: InkWell(onTap: () {}, child: Text('Resend')))
                      : null,
                  new PopupMenuItem<String>(
                      value: 'value04',
                      child: InkWell(
                          onTap: () {
                            bus.emit('delete_chat_item', widget.id);
                          },
                          child: new Text('Delete')))
                ]);
          },
          child: Container(
              // width: 200.0,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 116.0),
              // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Flexible(
                    fit: FlexFit.loose, child: buildErrMsgHeader()),
                Flexible(
                    flex: 9,
                    fit: FlexFit.loose,
                    child: Bubble(
                        margin: BubbleEdges.only(top: 5),
                        shadowColor: Colors.green,
                        elevation: 2,
                        alignment: Alignment.topRight,
                        nip: BubbleNip.rightTop,
                        color: Color.fromARGB(255, 225, 255, 199),
                        child: Text(
                          widget.text,
                          // overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black),
                        ))),
              ])));
    } else {
      return GestureDetector(
          onTapDown: _storePosition,
          onLongPress: () {
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject();
            showMenu(
                context: context,
                position: RelativeRect.fromRect(
                    _tapPosition & Size(40, 40), // smaller rect, the touch area
                    Offset.zero & overlay.size // Bigger rect, the entire screen
                    ),
                items: <PopupMenuItem<String>>[
                  new PopupMenuItem<String>(
                      value: 'value01',
                      child: InkWell(onTap: () {}, child: new Text('Copy'))),
                  new PopupMenuItem<String>(
                      value: 'value03',
                      child: InkWell(onTap: () {}, child: new Text('Quote'))),
                  new PopupMenuItem<String>(
                      value: 'value04',
                      child: InkWell(
                          onTap: () {
                            bus.emit('delete_chat_item', widget.id);
                          },
                          child: new Text('Delete')))
                ]);
          },
          child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 148.0),
              // decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Bubble(
                  margin: BubbleEdges.only(top: 5),
                  shadowColor: Colors.grey,
                  elevation: 2,
                  alignment: Alignment.topLeft,
                  nip: BubbleNip.leftTop,
                  child: Text(
                    widget.text,
                    style: TextStyle(color: Colors.black),
                  ))));
    }
  }

  Widget buildTimeStamp(int nowTimeStamp) {
    // var nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
    if (widget.timestampFlag) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                DateFormat('dd MMM kk:mm')
                    .format(DateTime.fromMillisecondsSinceEpoch(nowTimeStamp)),
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.normal),
              ),
            )
          ]);
    } else
      return Container();
  }

  Widget buildUserPic() {
    if (widget.isSelf) {
      return Container(
        // height: 40.0,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(
          radius: 25.0,
          child: new Text(
            widget.username[0].toUpperCase(),
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(
          radius: 25.0,
          child: new Text(
            widget.username[0].toUpperCase(),
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelf) {
      return new SizeTransition(
          key: UniqueKey(),
          sizeFactor: new CurvedAnimation(
              parent: widget.animationController, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(children: <Widget>[
                buildTimeStamp(widget.timestamp),
                Row(
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          // new Text(_name, style: Theme.of(context).textTheme.subhead),
                          buildUsername(),
                          buildTextSection(context),
                        ]),
                    buildUserPic()
                  ],
                  mainAxisAlignment:
                      MainAxisAlignment.end, // aligns the chatitem to right end
                ),
              ])));
    } else {
      // This is a received message
      return SizeTransition(
          key: UniqueKey(),
          sizeFactor: new CurvedAnimation(
              parent: widget.animationController, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(children: <Widget>[
                buildTimeStamp(widget.timestamp),
                Row(children: <Widget>[
                  buildUserPic(),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // new Text(_name, style: Theme.of(context).textTheme.subhead),
                      buildUsername(),
                      buildTextSection(context),
                    ],
                  )
                ]),
              ])));
    }
  }
}
