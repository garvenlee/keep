import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bubble/bubble.dart';

class ChatItemWidget extends StatelessWidget {
  final bool isSelf;
  final String text;
  final String username;
  final bool timestampFlag;
  final int timestamp;
  final AnimationController animationController;

  ChatItemWidget(
      {this.username,
      this.text,
      this.animationController,
      this.isSelf,
      this.timestampFlag,
      this.timestamp
      });

  Widget buildUsername() {
    return Container(
        // margin: EdgeInsets.only(bottom: 5.0),
        child: Text(username,
            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)));
  }

  Widget buildTextSection() {
    if (isSelf) {
      return Container(
        constraints: BoxConstraints(maxWidth: 200.0),
        child: Bubble(
        margin: BubbleEdges.only(top: 5),
        shadowColor: Colors.green,
        elevation: 2,
        alignment: Alignment.topRight,
        nip: BubbleNip.rightTop,
        color: Color.fromARGB(255, 225, 255, 199),
        child: Text(
          this.text,
          style: TextStyle(color: Colors.black),
        ),
      ));
    } else {
      return Container(
        constraints: BoxConstraints(maxWidth: 200.0),
        child: Bubble(
        margin: BubbleEdges.only(top: 5),
        shadowColor: Colors.grey,
        elevation: 2,
        alignment: Alignment.topLeft,
        nip: BubbleNip.leftTop,
        child: Text(
          this.text,
          style: TextStyle(color: Colors.black),
      )));
    }
  }

  Widget buildTimeStamp(int nowTimeStamp) {
    // var nowTimeStamp = DateTime.now().millisecondsSinceEpoch;
    if (timestampFlag) {
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
    if (isSelf) {
      return Container(
        // height: 40.0,
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(
          radius: 25.0,
          child: new Text(
            username[0],
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
            username[0],
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSelf) {
      return new SizeTransition(
          sizeFactor: new CurvedAnimation(
              parent: animationController, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(children: <Widget>[
            buildTimeStamp(this.timestamp),
            Row(children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      // new Text(_name, style: Theme.of(context).textTheme.subhead),
                      buildUsername(),
                      buildTextSection(),
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
          sizeFactor: new CurvedAnimation(
              parent: animationController, curve: Curves.easeOut),
          axisAlignment: 0.0,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(children: <Widget>[
            buildTimeStamp(this.timestamp),
            Row(children: <Widget>[
              buildUserPic(),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // new Text(_name, style: Theme.of(context).textTheme.subhead),
                  buildUsername(),
                  buildTextSection(),
                ],
              )
            ]),
          ])));
    }
  }
}
