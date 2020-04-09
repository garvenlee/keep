import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:keep/utils/status.dart';
import 'package:keep/utils/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:keep/models/user.dart';
import 'package:keep/UI/Login/login_widget.dart';
import 'package:keep/global/global_styles.dart';
import 'package:keep/UI/Login/login_screen_presenter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String _holdEmail;

  LoginScreen(this._holdEmail);

  @override
  State<StatefulWidget> createState() {
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen>
    implements LoginScreenContract, AuthStateListener {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _emailController;
  final loginStyle = TextStyle(
      color: Colors.white70, fontFamily: 'Montserrat', fontSize: 15.0);
  BuildContext _ctx;
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isVision = false;
  String _email, _password;
  bool isLogedIn;

  LoginScreenPresenter _presenter;

  LoginScreenState() {
    _presenter = new LoginScreenPresenter(this);
    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);
  }

  @override
  void initState() {
    _validateLogin();
    super.initState();
    // print('widget: '+ widget._holdEmail);
    if (widget._holdEmail == 'admin') {
      _emailController = new TextEditingController();
    } else {
      _emailController = new TextEditingController(text: widget._holdEmail);
    }
  }

  Future _validateLogin() async {
    Future<dynamic> future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("isLogedIn");
    });
    future.then((val) {
      if (val == null) {
        setState(() {
          isLogedIn = false;
        });
      } else {
        setState(() {
          isLogedIn = true;
        });
      }
    }).catchError((_) {
      print("catchError");
    });
  }

  @override
  onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN)
      Navigator.of(_ctx).pushReplacementNamed("/home");
  }

  void _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      await Future.delayed(Duration(seconds: 3));
      _presenter.doLogin(_email, _password);
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // void _showSnackBar(String text) {
  //   scaffoldKey.currentState
  //       .showSnackBar(new SnackBar(content: new Text(text)));
  // }

  @override
  void onLoginError(String errorTxt) {
    // print('error===============================');
    showFlushBar(_ctx, _email, errorTxt, iconIndicator['error']);
    // _showSnackBar(errorTxt);
    setState(() {
      _isLoading = false;
      _isVision = true;
    });
  }

  @override
  void onLoginSuccess(User user) {
    setState(() {
      _isLoading = false;
      _isVision = false;
    });
    _doLogedIn(user);
    showFlushBar(_ctx, _email, "You have loged in!", iconIndicator['success']);
    Navigator.of(_ctx)
        .pushNamedAndRemoveUntil("/home", (Route<dynamic> route) => false);
  }

  _doLogedIn(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('isLogedIn', 'LogedIn');
    await prefs.setString('apiKey', user.apiKey);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('user_pic', user.userPic);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
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
                  buildErrorHint(context, _isVision),
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
          widgetStatusLogin(_isLoading),
        ]));
  }

  Widget _buildForm() {
    return new Form(
      // autovalidate: true,
      key: formKey,
      child: Padding(
          padding: const EdgeInsets.all(36.0),
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
        onSaved: (val) => _email = val,
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
        onSaved: (val) => _password = val,
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
