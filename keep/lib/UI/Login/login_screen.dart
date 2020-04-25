import 'dart:ui';
import 'dart:async';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:provider/provider.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:keep/global/connectivity_status.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/global/flush_status.dart';
import 'package:keep/UI/Login/login_widget.dart';
import 'package:keep/UI/Login/login_screen_presenter.dart';
import 'package:keep/models/user.dart';
import 'package:keep/utils/socket_util.dart';
import 'package:keep/utils/event_util.dart';

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
  final loginStyle = TextStyle(
      color: Colors.white70, fontFamily: 'Montserrat', fontSize: 15.0);
  BuildContext _ctx;
  bool _obscureText = true;
  bool _isLoading = false;
  String _email, _password;
  String apiKey;
  // Get our connection status from the provider
  var connectionStatus;
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
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    _emailController.dispose();
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

  void _submit() async {
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
    setState(() => _isLoading = false);
    UserProvider.saveUser(user);
    // login post请求成功后先进行socket连接测试
    await new SocketUtil().socket.then((socket) {
      // 若socket连接成功，就进入主页面
      bus.on('login', (data) {
        showFlushBar(
            _ctx, _email, "You have loged in!", iconIndicator['success']);
        FriendProvider.saveFriends(user.userId)
            .then((_) => Timer(Duration(milliseconds: 1500), () {
                  Navigator.of(_ctx).pushNamedAndRemoveUntil(
                      "/home", (Route<dynamic> route) => false);
                }));
      });

      // 这个error当服务器正常开启时一般不会触发
      bus.on('login-error', (data) {
        showFlushBar(
            _ctx, _email, "There is uncertain error!", iconIndicator['error']);
      });

      // 如果socket连接被拦截，显示提示栏
      bus.on('authorized', (data) {
        if (data == 'Not authorized') {
          showFlushBar(
              _ctx, _email, "You have not authorized!", iconIndicator['error']);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    var loginForm = _buildForm();
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
        key: scaffoldKey,
        body: new Stack(children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage("assets/images/screen2.jpg"),
                      fit: BoxFit.cover)),
              child: SingleChildScrollView(
                  child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(children: <Widget>[
                  UserPic(),
                  buildSpace(context),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: Colors.black12.withAlpha(110),
                      border: Border.all(
                        width: 0.1,
                        style: BorderStyle.none,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: loginForm,
                  )
                ]),
              ))),
          widgetStatusLogin(_isLoading, 'Please wait.'),
        ]));
  }

  Widget _buildForm() {
    return new Form(
      // autovalidate: true,
      key: formKey,
      child: Padding(
          padding: const EdgeInsets.only(
              left: 36.0, right: 36.0, top: 15.0, bottom: 36.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              widgetLabelTxt(),
              _buildEmail(),
              _buildPwd(),
              _buildResetPwd(),
              _buildBtn(),
              WidgetLabelContinueWith(),
              WidgetLoginViaSocialMedia(),
            ],
          )),
    );
  }

  Widget _buildEmail() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        onSaved: (val) => setState(() {
          _email = val;
        }),
        controller: _emailController,
        validator: (val) => judgeEmail(val),
        style: loginStyle,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          hintStyle: TextStyle(
              fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
          prefixIcon: Icon(Icons.email, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
              color: Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPwd() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        obscureText: _obscureText,
        validator: (val) => judgePwd(val),
        onSaved: (val) => setState(() {
          _password = val;
        }),
        style: loginStyle,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          hintStyle: TextStyle(
              fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
          prefixIcon: Icon(Icons.lock, color: Colors.white70),
          suffixIcon: IconButton(
              onPressed: _toggle,
              icon: Icon(Icons.remove_red_eye),
              color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(
              color: Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetPwd() {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Register?',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: 'NanumGothic',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(_ctx).pushNamed("/register");
                  },
                ),
                FlatButton(
                  child: Text(
                    'Forget Password?',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: 'NanumGothic',
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(_ctx).pushNamed("/forget");
                  },
                ),
              ]),
        )
      ],
    );
  }

  Widget _buildBtn() {
    return Wrap(children: <Widget>[
      Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: MaterialButton(
            height: 40.0,
            color: Colors.white.withAlpha(145),
            splashColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(32.0),
                side: BorderSide(color: Colors.black54)),
            onPressed: _submit,
            child: Text("Log in",
                style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'NanumGothic',
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0)),
          ))
    ]);
  }
}
