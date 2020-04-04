import 'package:flutter/material.dart';
import 'package:keep/global/global_styles.dart';
import 'package:flutter_swiper/flutter_swiper.dart'; // 引入头文件

class InnerSwiper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _InnerSwiperState();
  }
}

class _InnerSwiperState extends State<InnerSwiper> {
  List<Widget> widgetList = [];

  Widget _buildImage(String imagePath) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
    );
  }

  @override
  void initState() {
    for (int i = 0; i < 3; i++) {
      widgetList.add(_buildImage(imageLists[i]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(MediaQuery.of(context).size.height * 0.07),
          child: SafeArea(
            top: true,
            child: Offstage(),
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            new Swiper(
              duration: 1200,
              outer: false,
              // loop: true,
              itemCount: imageLists.length,
              // control: new SwiperControl(),
              pagination: SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                      color: Colors.white70, // 其他点的颜色
                      activeColor: Colors.redAccent, // 当前点的颜色
                      // space: 2, // 点与点之间的距离
                      // activeSize: 20 // 当前点的大小
                      )),
              itemBuilder: (BuildContext context, int index) {
                return widgetList[index];
              },
              autoplay: true,
              autoplayDelay: 4000,
              autoplayDisableOnInteraction: true,
              // itemWidth: MediaQuery.of(context).size.width,
            ),
            getEntrancePage(context),
          ],
        ));
  }
}

Widget getEntrancePage(BuildContext context) {
  return Column(
    children: <Widget>[
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
      ),
      Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.15,
              vertical: 24.0),
          width: MediaQuery.of(context).size.width * 0.7,
          child: MaterialButton(
            color: Colors.white70,
            splashColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black26)),
            onPressed: () {
              Navigator.of(context).pushNamed("/login");
            },
            child: Text("Login", style: entranceStyle),
          )),
      Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: MaterialButton(
            color: Colors.white70,
            splashColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black26)),
            onPressed: () {
              Navigator.of(context).pushNamed("/register");
            },
            child: Text("Register Now", style: entranceStyle),
          )),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.16,
      ),
      Text('Now! Quick login use Touch ID',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      SizedBox(
        height: 15.0,
      ),
      Icon(
        Icons.fingerprint,
        color: Colors.white,
        size: 60,
      ),
      SizedBox(
        height: 15.0,
      ),
      Text('Use Touch ID',
          style: TextStyle(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          )),
    ],
  );
}
