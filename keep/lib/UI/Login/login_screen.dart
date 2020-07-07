// import 'dart:html';
import 'dart:ui';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
// import 'package:keep/widget/component_widget.dart';
import 'package:keep/widget/flush_status.dart';
import 'package:keep/UI/Login/login_widget.dart';
import 'package:keep/UI/Login/login_screen_presenter.dart';
import 'package:keep/models/user.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/service/note_presenter.dart';
import 'package:keep/service/todo_presenter.dart';
import 'package:keep/service/group_presenter.dart';
import 'package:keep/service/message_presenter.dart';
import 'package:keep/settings/status_config.dart';
import 'package:keep/utils/reg_expression.dart';
import 'package:keep/settings/styles.dart'
    show UserEntranceTextStyle, UserEntranceIcons, UserEntranceDecoration;

class LoginScreen extends StatefulWidget {
  final String _holdEmail;

  LoginScreen(this._holdEmail);

  @override
  State<StatefulWidget> createState() {
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>
    implements LoginScreenContract {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _emailController;
  BuildContext _ctx;
  bool _obscureText = true;
  bool _isLoading = false;
  String _email, _password;
  String apiKey;
  bool _offline = false;

  // set timeout
  Timer _timer;
  int _secondDelay = 3;
  final oneSec = const Duration(seconds: 1);

  LoginScreenPresenter _presenter;

  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void netErrIndicatorTimeout() {
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_secondDelay < 1) {
            setState(() {
              _isLoading = false;
              _secondDelay = 3;
              _showSnackBar(_offline
                  ? loginErrorHint['netError']
                  : loginErrorHint['loginError']);
            });
            timer.cancel();
          } else {
            _secondDelay = _secondDelay - 1;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget._holdEmail == 'admin') {
      _emailController = new TextEditingController();
    } else {
      _emailController = new TextEditingController(text: widget._holdEmail);
    }
    // 或用于进行二次登录控制
    apiKey = UserProvider.getApiKey() ?? 'null';
  }

  void _submit(connectionStatus) async {
    _unfocus();
    final form = formKey.currentState;
    if (form.validate()) {
      if (connectionStatus == ConnectivityStatus.Available) {
        print('network available.');
        setState(() {
          _offline = false;
          _isLoading = true;
        });
        form.save();
        await Future.delayed(Duration(seconds: 3));
        _presenter.doLogin(_email, _password);
      } else {
        print('network unavailable.');
        setState(() {
          _offline = true;
          _isLoading = true;
        });
        netErrIndicatorTimeout();
      }
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void onLoginError(String errorTxt) {
    // print('error===============================');
    showFlushBar(_ctx, _email, errorTxt, iconIndicator['error']);
    setState(() => _isLoading = false);
  }

  @override
  void onLoginSuccess(User user) async {
    UserProvider.saveUser(user);
    FriendProvider.saveFriends(user.userId);
    NotePresenter.getCollections(user.userId); // 等待抓取服务器的NOTE
    TodoPresenter.getCollections(user.userId);
    GroupPresenter.saveGroups(user.userId);

    MessagePresenter.saveMessages(user.userId);
    Future.delayed(Duration(seconds: 3), () {
      setState(() => _isLoading = false);
      showFlushBar(
          _ctx, _email, "You have loged in!", iconIndicator['success']);
      Timer(Duration(milliseconds: 2000), () {
        Navigator.of(_ctx)
            .pushNamedAndRemoveUntil("/home", (Route<dynamic> route) => false);
      });
    });
  }

  void _unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(_ctx);
    print('unfocus');
    if (!currentFocus.hasPrimaryFocus) {
      print('unfocus');
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    var loginForm = _buildForm();
    return GestureDetector(
        onTap: () => _unfocus(),
        child: new Scaffold(
            appBar: PreferredSize(
              preferredSize:
                  // Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
                  Size.fromHeight(ScreenUtil.screenHeight * 0.2),
              child: SafeArea(
                top: true,
                child: Offstage(),
              ),
            ),
            resizeToAvoidBottomPadding: false,
            key: scaffoldKey,
            body: new Stack(children: <Widget>[
              Container(
                  // height: MediaQuery.of(context).size.height,
                  height: ScreenUtil.screenHeight,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: new AssetImage("assets/images/screen2.jpg"),
                          fit: BoxFit.cover)),
                  child: Container(
                    // width: MediaQuery.of(context).size.width,
                    width: ScreenUtil.screenWidth,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: ScreenUtil.screenHeight * 0.07),
                          UserPic(),
                          SizedBox(height: ScreenUtil.screenHeight * 0.07),
                          Container(
                              height: ScreenUtil.screenHeight * 0.58,
                              width: ScreenUtil.screenWidth * 0.85,
                              decoration: BoxDecoration(
                                  color: Colors.black12.withAlpha(110),
                                  border: Border.all(
                                      width: 1.w, style: BorderStyle.none),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(36.w))),
                              child: loginForm)
                        ]),
                  )),
              widgetStatusLogin(_isLoading, 'Please wait.'),
            ])));
  }

  Widget _buildForm() {
    return new Form(
      key: formKey,
      child: Stack(children: [
        Padding(
            padding: EdgeInsets.all(56.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                widgetLabelTxt(),
                SizedBox(height: 112.h),
                _buildEmail(),
                SizedBox(height: 16.h),
                _buildPwd(),
              ],
            )),
        Positioned(
            top: ScreenUtil.screenHeight * 0.25,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 56.w, vertical: 35.h),
                width: ScreenUtil.screenWidth * 0.85,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildResetPwd(),
                      _buildBtn(),
                      WidgetLabelContinueWith(),
                      WidgetLoginViaSocialMedia(),
                    ])))
      ]),
    );
  }

  Widget _buildEmail() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        onSaved: (val) => setState(() => _email = val),
        controller: _emailController,
        validator: (val) => judgeEmail(val),
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 15.h),
          hintText: "Email",
          hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
          prefixIcon: UserEntranceIcons.email,
          border: UserEntranceDecoration.border,
          enabledBorder: UserEntranceDecoration.enableBorder,
        ),
      ),
    );
  }

  Widget _buildPwd() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        obscureText: _obscureText,
        validator: (val) => judgePwd(val),
        onSaved: (val) => setState(() => _password = val),
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 15.h),
          hintText: "Password",
          hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
          // fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
          prefixIcon: UserEntranceIcons.password,
          suffixIcon: IconButton(
              onPressed: _toggle,
              icon: Icon(Icons.remove_red_eye),
              color: Colors.white70),
          border: UserEntranceDecoration.border,
          enabledBorder: UserEntranceDecoration.enableBorder,
        ),
      ),
    );
  }

  Widget _buildResetPwd() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              child: Text('Register?',
                  style: UserEntranceTextStyle.loginHintTextStyle),
              onPressed: () => Navigator.of(_ctx).pushNamed("/register")),
          FlatButton(
              child: Text('Forget Password?',
                  style: UserEntranceTextStyle.loginHintTextStyle),
              onPressed: () => Navigator.of(_ctx).pushNamed("/forget")),
        ]);
  }

  Widget _buildBtn() {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, child) {
          return Container(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              margin: EdgeInsets.only(top: 54.h),
              width: ScreenUtil.screenWidth * 0.3,
              child: MaterialButton(
                  height: 100.h,
                  color: Colors.white.withAlpha(145),
                  splashColor: Colors.blue,
                  shape: UserEntranceDecoration.shape,
                  onPressed: () => _submit(connectionStatus),
                  child: child));
        },
        child: Text("Log in", style: UserEntranceTextStyle.loginBtnTextStyle));
  }
}
