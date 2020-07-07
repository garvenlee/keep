import 'package:flutter/material.dart';

var statusColor = {'active': Colors.green, 'inactive': Colors.grey};
double radius = 4.0;

class DotIndicator extends StatelessWidget {
  final String status;
  const DotIndicator({@required this.status, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(right: 5.0),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: statusColor[status],
          )),
      Text(status,
          style: TextStyle(
              fontSize: 14.0,
              color: Colors.white54,
              fontWeight: FontWeight.w400))
    ]);
  }
}
