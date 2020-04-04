import 'package:flutter/material.dart';

class WidgetIconNoting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return Container(
        height: 200.0,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: mediaQuery.padding.top > 0 ? mediaQuery.padding.top : 20.0,
            right: 16.0,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 200.0,
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/login_logo.jpg',
                        // width: mediaQuery.size.width / 1.5,
                        // width: 200,
                        height: 50,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  )),
              SizedBox(
                width: 25.0
              ),
              Container(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Center(
                        child: Text(
                          'Keep App',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontFamily: 'NanumGothic',
                            color: Colors.white70,
                          ),
                        ),
                      ))),
            ],
          ),
        )));
  }
}