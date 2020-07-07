import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'note_logo.dart';
import 'package:keep/widget/flush_status.dart';
import 'package:keep/utils/reg_expression.dart';
import 'package:keep/settings/status_config.dart';
import 'package:keep/UI/Register/register_screen_presenter.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/settings/styles.dart'
    show UserEntranceTextStyle, UserEntranceIcons, UserEntranceDecoration;

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen>
    implements RegisterScreenContract {
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _pass = TextEditingController();

  BuildContext _registerCtx;
  bool _isLoading = false;
  bool _obscureText = true;
  String _username, _email, _password, _phone;
  RegisterScreenPresenter _presenter;

  RegisterScreenState() {
    _presenter = new RegisterScreenPresenter(this);
  }

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  void _submit(connectionStatus) async {
    _unfocus();
    final form = _formKey.currentState;

    if (form.validate()) {
      if (connectionStatus == ConnectivityStatus.Available) {
        setState(() => _isLoading = true);
        form.save();
        await Future.delayed(Duration(seconds: 3));
        _presenter.doRegister(_username, _email, _password, _phone);
      } else {
        _showSnackBar('Please check your internet.');
      }
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void onRegisterError(String errorTxt) {
    // _showSnackBar(errorTxt);
    showFlushBar(_registerCtx, _username, errorTxt, iconIndicator['error']);
    setState(() => _isLoading = false);
  }

  @override
  void onRegisterSuccess(String hintTxt) async {
    // _showSnackBar(user.username + " has registered successfullly!");
    // present status on the screen
    showFlushBar(_registerCtx, _username, hintTxt, iconIndicator['success']);
    setState(() => _isLoading = false);

    // jump to login page
    Timer(Duration(seconds: 2), () {
      Navigator.of(_registerCtx).pushNamedAndRemoveUntil(
          "/hold-login", ModalRoute.withName('/'),
          arguments: {'email': _email});
    });
  }

  void _unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(_registerCtx);
    // print('unfocus');
    if (!currentFocus.hasPrimaryFocus) {
      // print('unfocus');
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _registerCtx = context;
    var registerForm = _buildForm();
    return GestureDetector(
        onTap: () => _unfocus(),
        child: new Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(ScreenUtil.screenHeight * 0.07),
              child: SafeArea(
                top: true,
                child: Offstage(),
              ),
            ),
            resizeToAvoidBottomPadding: false,
            key: _scaffoldKey,
            body: Container(
                height: ScreenUtil.screenHeight,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage("assets/images/screen2.jpg"),
                      fit: BoxFit.cover),
                ),
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  SizedBox(height: ScreenUtil.screenHeight * 0.06),
                  WidgetIconNoting(),
                  SizedBox(height: ScreenUtil.screenHeight * 0.03),
                  Container(
                      width: ScreenUtil.screenWidth * 0.85,
                      height: ScreenUtil.screenHeight * 0.60,
                      decoration: BoxDecoration(
                        color: Colors.black12.withAlpha(110),
                        border: Border.all(
                          width: 1.w,
                          style: BorderStyle.none,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(36.w)),
                      ),
                      child: registerForm)
                ])))));
  }

  Widget _buildBtn() {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, child) {
          return Container(
              width: ScreenUtil.screenWidth * 0.3,
              margin: EdgeInsets.only(top: 54.h),
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: MaterialButton(
                  height: 100.h,
                  color: Colors.white.withAlpha(125),
                  splashColor: Colors.blue,
                  shape: UserEntranceDecoration.shape,
                  onPressed: () => _submit(connectionStatus),
                  child: child));
        },
        child:
            Text("Register", style: UserEntranceTextStyle.loginBtnTextStyle));
  }

  Widget _buildUsernameField() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        onSaved: (val) => _username = val,
        validator: (val) => judgeUsername(val),
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
            hintText: "Username",
            hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
            prefixIcon: UserEntranceIcons.username,
            border: UserEntranceDecoration.border,
            enabledBorder: UserEntranceDecoration.enableBorder),
      ),
    );
  }

  Widget _buildPhoneField() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        onSaved: (val) => _phone = val,
        validator: (val) => judgePhoneNumber(val),
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
          hintText: "Phone",
          hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
          prefixIcon: UserEntranceIcons.phone,
          border: UserEntranceDecoration.border,
          enabledBorder: UserEntranceDecoration.enableBorder,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        onSaved: (val) => _email = val,
        validator: (val) => judgeEmail(val),
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
            hintText: "Email",
            hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
            prefixIcon: UserEntranceIcons.email,
            border: UserEntranceDecoration.border,
            enabledBorder: UserEntranceDecoration.enableBorder),
      ),
    );
  }

  Widget _buildPwdField() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
        controller: _pass,
        obscureText: _obscureText,
        validator: (val) => judgePwd(val),
        onSaved: (val) => _password = val,
        style: UserEntranceTextStyle.loginFieldInputTextStyle,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
            hintText: "Password",
            hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
            prefixIcon: UserEntranceIcons.password,
            // suffixIcon: Icon(Icons.remove_red_eye, color: Colors.white70),
            suffixIcon: IconButton(
                onPressed: _toggle,
                icon: Icon(Icons.remove_red_eye),
                color: Colors.white70),
            border: UserEntranceDecoration.border,
            enabledBorder: UserEntranceDecoration.enableBorder),
      ),
    );
  }

  Widget _buildConfirmPwdField() {
    return new Padding(
      padding: EdgeInsets.all(8.w),
      child: new TextFormField(
          obscureText: true,
          validator: (val) => judgeConfirmPwd(val, _pass.text),
          style: UserEntranceTextStyle.loginFieldInputTextStyle,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 15.w),
              hintText: "Confirm Password",
              hintStyle: UserEntranceTextStyle.loginFieldHintStyle,
              prefixIcon: UserEntranceIcons.password,
              suffixIcon: IconButton(
                  onPressed: _toggle,
                  icon: Icon(Icons.remove_red_eye),
                  color: Colors.white70),
              border: UserEntranceDecoration.border,
              enabledBorder: UserEntranceDecoration.enableBorder)),
    );
  }

  Widget _buildLabel() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 15.w),
        child: new Text("Sign up to Your Account",
            textScaleFactor: 1.5,
            style: UserEntranceTextStyle.subHeaderRegisterLabelTextStyle));
  }

  Widget _buildForm() {
    return new Form(
        key: _formKey,
        child: Stack(children: [
          Padding(
            padding: EdgeInsets.all(56.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildLabel(),
                SizedBox(height: 112.h),
                _buildUsernameField(),
                _buildEmailField(),
                _buildPhoneField(),
                _buildPwdField(),
                _buildConfirmPwdField(),
              ],
            ),
          ),
          Positioned(
              top: ScreenUtil.screenHeight * 0.48,
              child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 56.w, vertical: 35.h),
                  width: ScreenUtil.screenWidth * 0.85,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _isLoading
                          ? new CircularProgressIndicator(strokeWidth: 3)
                          : _buildBtn())))
        ]));
  }
}
