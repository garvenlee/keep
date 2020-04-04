import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'note_logo.dart';
import 'package:flutter/material.dart';
import 'package:keep/utils/status.dart';
import 'package:keep/global/global_styles.dart';
import 'package:keep/UI/Register/register_screen_presenter.dart';

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
  final registerStyle = TextStyle(
      color: Colors.white70, fontFamily: 'Montserrat', fontSize: 15.0);

  BuildContext _registerCtx;
  bool _isLoading = false;
  bool _obscureText = true;
  String _username, _email, _password;
  RegisterScreenPresenter _presenter;

  RegisterScreenState() {
    _presenter = new RegisterScreenPresenter(this);
  }

  void _submit() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      await Future.delayed(Duration(seconds: 3));
      _presenter.doRegister(_username, _email, _password);
    }
  }

  // void _showSnackBar(String text) {
  //   _scaffoldKey.currentState
  //       .showSnackBar(new SnackBar(content: new Text(text)));
  // }

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

    // hold the email
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('===================' + _email);
    await prefs.setString('email', _email);

    // jump to login page
    Timer(Duration(seconds: 2), () {
      Navigator.of(_registerCtx).pushNamedAndRemoveUntil(
          "/hold-login", ModalRoute.withName('/'),
          arguments: {'email': _email});
    });
    // Navigator.of(_registerCtx).pop();
  }

  @override
  Widget build(BuildContext context) {
    _registerCtx = context;
    var registerBtn = _buildBtn();
    var registerForm = _buildForm(registerBtn);
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
        key: _scaffoldKey,
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: new BoxDecoration(
              image: new DecorationImage(
                  image: new AssetImage("assets/images/screen2.jpg"),
                  fit: BoxFit.cover),
            ),
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              WidgetIconNoting(),
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
                  child: Center(
                      child: Column(children: <Widget>[
                    Container(
                      // color: Colors.grey.withOpacity(0.6),
                      child: Padding(
                        padding: const EdgeInsets.all(36.0),
                        child: registerForm,
                      ),
                    )
                  ])))
            ]))));
  }

  Widget _buildBtn() {
    return Padding(
        padding: EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 0),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: MaterialButton(
              height: 40.0,
              color: Colors.white.withAlpha(125),
              splashColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(32.0),
                  side: BorderSide(color: Colors.black54)),
              onPressed: _submit,
              child: Text("Register",
                  style: TextStyle(
                      color: Colors.black87,
                      fontFamily: 'NanumGothic',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.0)),
            )));
  }

  Widget _buildUsernameField() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        onSaved: (val) => _username = val,
        validator: (val) => val.isEmpty ? "username don't be empty!" : null,
        style: registerStyle,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Username",
            hintStyle: TextStyle(
                fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
            prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide(
                color: Colors.white60,
              ),
            )),
      ),
    );
  }

  Widget _buildEmailField() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        onSaved: (val) => _email = val,
        validator: (val) => judgeEmail(val),
        style: registerStyle,
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

  Widget _buildPwdField() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
        controller: _pass,
        obscureText: _obscureText,
        validator: (val) => judgePwd(val),
        onSaved: (val) => _password = val,
        style: registerStyle,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
            hintStyle: TextStyle(
                fontSize: 15.0, color: Colors.amberAccent.withOpacity(0.8)),
            prefixIcon: Icon(Icons.lock, color: Colors.white70),
            // suffixIcon: Icon(Icons.remove_red_eye, color: Colors.white70),
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
            )),
      ),
    );
  }

  Widget _buildConfirmPwdField() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new TextFormField(
          obscureText: true,
          validator: (val) => judgePwd(val),
          style: registerStyle,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Confirm Password",
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
                )),
          )),
    );
  }

  Widget _buildLabel() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
        child: new Text("Sign Up to Your Account",
            textScaleFactor: 1.5, style: TextStyle(color: Colors.white70)));
  }

  Widget _buildForm(Widget btn) {
    return new Form(
      // autovalidate: true,
      key: _formKey,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildLabel(),
          _buildUsernameField(),
          _buildEmailField(),
          _buildPwdField(),
          _buildConfirmPwdField(),
          _isLoading ? new CircularProgressIndicator() : btn,
        ],
      ),
    );
  }
}
