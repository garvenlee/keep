import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:keep/global/connectivity_status.dart';
import 'package:keep/global/flush_status.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/UI/Forget/reset_screen_presenter.dart';
import 'package:keep/utils/sputil.dart';
import 'package:provider/provider.dart';

class ForgetScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ForgetScreenState();
  }
}

class ForgetScreenState extends State<ForgetScreen>
    implements ResetScreenContract {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final forgetStyle = TextStyle(
      color: Colors.white70, fontFamily: 'Montserrat', fontSize: 15.0);
  final TextEditingController _emailController = TextEditingController();
  BuildContext _ctx;
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isVision = false;
  String _email, _password, _code;
  var connectionStatus;

  // set timeout
  Timer _timer;
  int _secondDelay = 3;
  final oneSec = const Duration(seconds: 1);

  ResetScreenPresenter _presenter;

  ForgetScreenState() {
    _presenter = new ResetScreenPresenter(this);
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _emailController.dispose();
    super.dispose();
  }

  void netErrIndicatorTimeout() {
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_secondDelay < 1) {
            _isLoading = false;
            _secondDelay = 3;
            _showSnackBar('Please check your internet.');
            _timer.cancel();
          } else {
            print('sub one');
            _secondDelay = _secondDelay - 1;
          }
        },
      ),
    );
  }

  void _onCheck() {
    String email = _emailController.text;
    var res =
        !emailReg.hasMatch(email) ? "Please check the email's format" : null;
    if (res != null) {
      onCheckError("please check the email.");
    } else if (connectionStatus == ConnectivityStatus.Available) {
      _presenter.doCheck(email);
    } else {
      _showSnackBar('Please check your internet.');
    }
  }

  void _onSubmit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      if (connectionStatus == ConnectivityStatus.Available) {
        setState(() => _isLoading = true);
        form.save();
        await Future.delayed(Duration(seconds: 3));
        _presenter.doReset(_email, _password, _code);
      } else {
        setState(() {
          _isLoading = true;
        });
        netErrIndicatorTimeout();
      }
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void onResetSuccess(String username) async {
    showFlushBar(_ctx, username, 'Password has been reset successfully.',
        iconIndicator['success']);
    setState(() => _isLoading = false);

    // jumpt to login page
    Timer(Duration(milliseconds: 1200), () {
      Navigator.of(_ctx).pushNamedAndRemoveUntil(
          "/hold-login", ModalRoute.withName('/'),
          arguments: {'email': _email});
    });
  }

  @override
  void onResetError(String errorTxt) {
    // _showSnackBar(errorTxt);
    showFlushBar(_ctx, _emailController.text, errorTxt, iconIndicator['error']);
    setState(() => _isLoading = false);
  }

  @override
  void onCheckSuccess(String code) async {
    print(code);
    showFlushBar(
        _ctx,
        _emailController.text,
        "verification code has been sent to your email.",
        iconIndicator['success']);
    setState(() => _isLoading = false);

    // hold the verification code
    SpUtil.putString('verification_code', code);
  }

  @override
  void onCheckError(String errorTxt) {
    showFlushBar(_ctx, _emailController.text, errorTxt, iconIndicator['error']);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    var resetForm = _buildForm();
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    return _buildSigninPage(resetForm);
  }

  Widget _buildForm() {
    return new Form(
        // autovalidate: true,
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: new Column(
            children: <Widget>[
              _buildLabelTxt(),
              _buildHintTxt(),
              _buildEmail(),
              _buildVCode(),
              _buildPwd(),
              SizedBox(
                height: 15.0,
              ),
              _buildResetTxt(),
              _buildBtn(),
            ],
          ),
        ));
  }

  Widget _buildSigninPage(Widget loginForm) {
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
                  fit: BoxFit.cover),
            )),
        Container(
            margin: EdgeInsets.only(
              top: 150.0,
              left: MediaQuery.of(context).size.width * 0.075,
            ),
            child: SingleChildScrollView(
                child: Container(
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
            ))),
        _checkWidgetStatusLogin(_isLoading),
      ]),
    );
  }

  Widget _buildBtn() {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        child: Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'NanumGothic',
            fontWeight: FontWeight.bold,
          ),
        ),
        color: Color(0xFF6C63FF).withOpacity(0.65),
        onPressed: () => _onSubmit(),
      ),
    );
  }

  Widget _buildEmail() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        controller: _emailController,
        onSaved: (val) => _email = val,
        validator: (val) {
          if (val.isEmpty) {
            return "email cannot be empty!";
          }
          return !emailReg.hasMatch(val)
              ? "Please check the email's format"
              : null;
        },
        style: forgetStyle,
        enabled: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blueGrey,
            ),
          ),
          labelText: 'Please enter your email ID',
          labelStyle: TextStyle(
              fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
          contentPadding: EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  Widget _buildPwd() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        obscureText: _obscureText,
        validator: (val) {
          if (val.isEmpty) {
            return "password cannot be empty!";
          }
          if (val.length < 8) {
            return "must be at least 8 characters!";
          } else if (val.length > 15) {
            return "must be at most 15 characters!";
          } else {
            return null;
          }
        },
        onSaved: (val) => _password = val,
        style: forgetStyle,
        enabled: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.blueGrey,
          )),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          // prefixIcon: Icon(Icons.lock, color: Colors.white70, size: 20.0,),
          suffixIcon: IconButton(
              onPressed: _toggle,
              icon: Icon(Icons.remove_red_eye),
              color: Colors.white70,
              iconSize: 20.0),
          labelText: "One new password",
          labelStyle: TextStyle(
              fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
        ),
      ),
    );
  }

  Widget _buildResetTxt() {
    var content;
    if (_isVision) {
      //如果数据不为空，则显示Text
      content = new Container(
          height: MediaQuery.of(context).size.height * 0.03,
          // color: Colors.white,
          child: new Text("Your password has been reset successful",
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600)));
    } else {
      content = new SizedBox.fromSize(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.05,
          // color: Colors.white,
        ),
      );
    }
    return content;
  }

  Widget _checkWidgetStatusLogin(bool isLoading) {
    if (isLoading) {
      return Center(
          child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
        ),
        child: Center(
          child: Wrap(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(16.0),
                  ),
                ),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Platform.isIOS
                        ? CupertinoActivityIndicator()
                        : CircularProgressIndicator(),
                    SizedBox(height: 16.0),
                    Text('Please wait'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    } else {
      return Container();
    }
  }

  Widget _buildLabelTxt() {
    return Padding(
        padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 25.0),
        child: Text("Forget password",
            textScaleFactor: 1.5, style: TextStyle(color: Colors.redAccent)));
  }

  Widget _buildHintTxt() {
    return Container(
      width: MediaQuery.of(_ctx).size.width * 0.5,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(_ctx).size.width * 0.225 - 36.0),
      padding: EdgeInsets.only(bottom: 25.0),
      child: Container(
        child: Text('Make sure email is valid.',
            style: TextStyle(
                color: Colors.white70, fontFamily: 'Times New Romance')),
      ),
    );
  }

  Widget _buildVCode() {
    return IntrinsicHeight(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          new Flexible(
              flex: 5,
              child: Container(
                  // width: MediaQuery.of(_ctx).size.width * 0.45,
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 8.0),
                  child: new TextFormField(
                    onSaved: (val) => _code = val,
                    validator: (val) => judgeCode(val),
                    style: forgetStyle,
                    enabled: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blueGrey,
                        ),
                      ),
                      labelText: 'Code',
                      labelStyle: TextStyle(
                          fontSize: 15.0,
                          color: Colors.amberAccent.withOpacity(0.8)),
                      contentPadding: EdgeInsets.all(16.0),
                    ),
                  ))),
          new Flexible(
              flex: 3,
              child: Container(
                  height: 64.0,
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 8.0, 8.0),
                  // width: MediaQuery.of(_ctx).size.width * 0.2,
                  child: RaisedButton(
                    child: Text('Check',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NanumGothic',
                          fontWeight: FontWeight.bold,
                        )),
                    color: Color(0xFF6C63FF).withOpacity(0.65),
                    onPressed: () => _onCheck(),
                  ))),
        ]));
  }
}
