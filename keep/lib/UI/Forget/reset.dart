import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/settings/styles.dart'
    show UserEntranceDecoration, UserEntranceTextStyle;
import 'package:keep/widget/flush_status.dart';
import 'package:keep/utils/reg_expression.dart';
import 'package:keep/UI/Forget/reset_screen_presenter.dart';
import 'package:keep/data/sputil.dart';
import 'package:keep/settings/status_config.dart';
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
  final TextEditingController _emailController = TextEditingController();
  BuildContext _ctx;
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isVision = false;
  String _email, _password, _code;

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
    if (_timer != null) _timer.cancel();
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
            debugPrint('sub one');
            _secondDelay = _secondDelay - 1;
          }
        },
      ),
    );
  }

  void _onCheck(connectionStatus) {
    _unfocus();
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

  void _onSubmit(connectionStatus) async {
    _unfocus();
    final form = formKey.currentState;
    if (form.validate()) if (connectionStatus == ConnectivityStatus.Available) {
      setState(() => _isLoading = true);
      form.save();
      await Future.delayed(Duration(seconds: 3));
      _presenter.doReset(_email, _password, _code);
    } else {
      setState(() => _isLoading = true);
      netErrIndicatorTimeout();
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _toggle() => setState(() => _obscureText = !_obscureText);

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
    var resetForm = _buildForm();
    return GestureDetector(
        onTap: () => _unfocus(), child: _buildResetPage(resetForm));
  }

  Widget _buildResetPage(Widget resetForm) {
    return new Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(ScreenUtil.screenHeight * 0.07),
          child: SafeArea(
            top: true,
            child: Offstage(),
          ),
        ),
        resizeToAvoidBottomPadding: false,
        key: scaffoldKey,
        body: Container(
          height: ScreenUtil.screenHeight,
          decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("assets/images/screen2.jpg"),
                fit: BoxFit.cover),
          ),
          child: new Stack(children: <Widget>[
            SingleChildScrollView(
                padding: EdgeInsets.only(top: ScreenUtil.screenHeight * 0.2),
                child: Center(
                    child: Container(
                        width: ScreenUtil.screenWidth * 0.85,
                        height: ScreenUtil.screenHeight * 0.54,
                        decoration: BoxDecoration(
                          color: Colors.black12.withAlpha(110),
                          border:
                              Border.all(width: 1.w, style: BorderStyle.none),
                          borderRadius: BorderRadius.all(Radius.circular(36.w)),
                        ),
                        child: resetForm))),
            _checkWidgetStatusLogin(_isLoading),
          ]),
        ));
  }

  Widget _buildForm() {
    return new Form(
        key: formKey,
        child: Stack(children: [
          Container(
            padding: EdgeInsets.all(54.w),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildLabelTxt(),
                _buildHintTxt(),
                _buildEmail(),
                SizedBox(height: 16.h),
                _buildVCode(),
                SizedBox(height: 16.h),
                _buildPwd(),
              ],
            ),
          ),
          Positioned(
              top: ScreenUtil.screenHeight * 0.38,
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 56.w, vertical: 35.h),
                  width: ScreenUtil.screenWidth * 0.85,
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _buildResetTxt(),
                        _buildBtn(),
                      ])))
        ]));
  }

  Widget _buildBtn() {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, child) {
          return SizedBox(
            width: double.infinity,
            child: RaisedButton(
              child: child,
              color: Color(0xFF6C63FF).withOpacity(0.65),
              onPressed: () => _onSubmit(connectionStatus),
            ),
          );
        },
        child: Text('Submit', style: UserEntranceTextStyle.forgetBtnTextStyle));
  }

  Widget _buildEmail() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        controller: _emailController,
        onSaved: (val) => _email = val,
        validator: (val) => judgeEmail(val),
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        enabled: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: UserEntranceDecoration.forgetEnableBorder,
          labelText: 'Please enter your email ID',
          labelStyle: UserEntranceTextStyle.loginFieldHintStyle,
          contentPadding: EdgeInsets.fromLTRB(42.w, 15.h, 20.w, 15.h),
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
        onSaved: (val) => _password = val,
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        enabled: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: UserEntranceDecoration.forgetEnableBorder,
          contentPadding: EdgeInsets.fromLTRB(42.w, 15.h, 20.w, 15.h),
          suffixIcon: IconButton(
              onPressed: _toggle,
              icon: Icon(Icons.remove_red_eye),
              color: Colors.white70,
              iconSize: 20.0),
          labelText: "One new password",
          labelStyle: UserEntranceTextStyle.loginFieldHintStyle,
        ),
      ),
    );
  }

  Widget _buildResetTxt() {
    var content;
    if (_isVision) {
      content = new Container(
          height: MediaQuery.of(context).size.height * 0.03,
          child: new Text("Your password has been reset successful",
              style: UserEntranceTextStyle.forgetSucessHintTextStyle));
    } else {
      content = new SizedBox.fromSize(
        child: Container(
          height: ScreenUtil.screenHeight * 0.05,
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
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: Text("Forget password",
            textScaleFactor: 1.5,
            style: UserEntranceTextStyle.headerForgetLabelTextStyle));
  }

  Widget _buildHintTxt() {
    return Container(
      padding: EdgeInsets.only(bottom: 84.h),
      child: Container(
        child: Text('Make sure email is valid.',
            style: UserEntranceTextStyle.subHeaderForgetLabelTextStyle),
      ),
    );
  }

  Widget _buildVCode() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Flexible(
              flex: 5,
              child: Container(
                  padding: EdgeInsets.all(8.w),
                  child: new TextFormField(
                    onSaved: (val) => _code = val,
                    validator: (val) => judgeCode(val),
                    style: UserEntranceTextStyle.loginFieldInputTextStyle,
                    enabled: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: UserEntranceDecoration.forgetEnableBorder,
                      labelText: 'Code',
                      labelStyle: UserEntranceTextStyle.loginFieldHintStyle,
                      contentPadding:
                          EdgeInsets.fromLTRB(42.w, 15.h, 20.w, 15.h),
                    ),
                  ))),
          new Flexible(
              flex: 3,
              child: Container(
                  height: 140.h,
                  padding: EdgeInsets.fromLTRB(0, 8.w, 8.w, 8.w),
                  child: Consumer<ConnectivityStatus>(
                      builder: (context, connectionStatus, child) {
                        return RaisedButton(
                          child: child,
                          color: const Color(0xFF6C63FF).withOpacity(0.65),
                          onPressed: () => _onCheck(connectionStatus),
                        );
                      },
                      child: Text('Check',
                          style: UserEntranceTextStyle.forgetBtnTextStyle)))),
        ]);
  }
}
