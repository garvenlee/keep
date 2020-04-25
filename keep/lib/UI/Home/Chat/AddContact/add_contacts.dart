import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/global/global_tool.dart';
import 'package:keep/global/user_pic.dart';
import 'package:keep/global/connectivity_status.dart';
import 'package:keep/utils/socket_util.dart';

class AddContactsPage extends StatefulWidget {
  AddContactsPage({Key key}) : super(key: key);

  @override
  _AddContactsPageState createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage>
    with TickerProviderStateMixin {
  final int userOneId = UserProvider.getUserId();
  BuildContext _ctx;
  String headerText;
  var connectionStatus;
  bool _isLoading = false;

  String _firstname;
  String _lastname;
  String _email;
  // RestDatasource _api = new RestDatasource();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SocketIO _socket;

  @override
  void initState() {
    super.initState();
    initSocket().then((socket) {
      _socket = socket;
      _socket.on('friendRequestAck', (stream) {
        if (stream['status'] == 303) {
          _showSnackBar('request has been sent successfully.');
        } else if (stream['status'] == 404) {
          _showSnackBar(
              'Please check out, user ' + _email + ' does not exist!');
        } else {
          _showSnackBar('Sorry, come out an error.');
        }
      });
    });
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  initSocket() async {
    return await new SocketUtil().socket;
  }

  void _submit() {
    final form = _formKey.currentState;
    print('enter...');
    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      if (FriendProvider.isExist(_email)) {
        _showSnackBar(_email + ' has been your friend.');
      } else {
        if (connectionStatus == ConnectivityStatus.Available) {
          _socket.emit('friendRequest', [
            {"userOneId": userOneId, "twoEmail": _email}
          ]);
        } else {
          _showSnackBar('Please check your internet.');
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.Available) {
      headerText = 'Add Contacts';
    } else {
      headerText = 'Connecting...';
    }
    return new Scaffold(
        key: scaffoldKey,
        body: new Form(
            key: _formKey,
            child: SafeArea(
                child: new Column(children: <Widget>[
              buildHeader(),
              Row(
                children: [
                  buildAvatar(),
                  buildNameRegion(),
                ],
              ),
              buildEmailFeild(),
            ]))));
  }

  Widget buildHeader() {
    return Container(
        height: 50.0,
        decoration: BoxDecoration(color: Colors.blueGrey),
        padding: new EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(children: <Widget>[
          Container(
              width: MediaQuery.of(_ctx).size.width * 0.15 - 10.0,
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(_ctx).pop();
                  })),
          Container(
              width: MediaQuery.of(_ctx).size.width * 0.3,
              child: Text(headerText,
                  style: TextStyle(
                      // color: Colors.white70,
                      fontSize: 18.0))),
          Container(
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.4,
              padding: const EdgeInsets.all(5.0)),
          Container(
              width: MediaQuery.of(_ctx).size.width * 0.15 - 10.0,
              child: _isLoading
                  ? SpinKitRing(
                      color: Colors.lightBlue,
                      size: 28.0,
                      lineWidth: 2.5,
                    )
                  : IconButton(
                      icon: Icon(Icons.done), onPressed: () => _submit())),
        ]));
  }

  Widget buildFirstFeild() {
    return Container(
        width: MediaQuery.of(_ctx).size.width - 24.0 * 2 - 32.0 * 3,
        height: 40.0,
        child: new TextFormField(
          validator: (val) {
            return val.isEmpty ? 'First Name cannot be empty.' : null;
          },
          onChanged: (val) => setState(() {
            _firstname = val;
          }),
          onSaved: (val) => setState(() => _firstname = val),
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'First name(required)',
            hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            contentPadding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          ),
        ));
  }

  Widget buildLastField() {
    return Container(
        width: MediaQuery.of(_ctx).size.width - 24.0 * 2 - 32.0 * 3,
        height: 40.0,
        child: TextFormField(
          onSaved: (val) => setState(() => _lastname = val),
          decoration: InputDecoration(
            hintText: 'Last name(Optional)',
            hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            contentPadding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          ),
        ));
  }

  Widget buildAvatar() {
    return Padding(
        padding:
            EdgeInsets.only(left: 24.0, top: 32.0, right: 24.0, bottom: 32.0),
        child: normalUserPic(
            username: _firstname ?? '',
            picRadius: 32.0,
            fontSize: 20.0,
            fontColor: Colors.white,
            bgColor: Colors.indigoAccent));
  }

  Widget buildNameRegion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.only(bottom: 8.0), child: buildFirstFeild()),
        Container(
            margin: EdgeInsets.only(bottom: 8.0), child: buildLastField()),
      ],
    );
  }

  Widget buildEmailFeild() {
    return Container(
        margin: EdgeInsets.only(top: 8.0),
        width: MediaQuery.of(_ctx).size.width - 24.0 - 32.0,
        // height: 40.0,
        child: TextFormField(
          validator: (val) => judgeEmail(val),
          onSaved: (val) => setState(() => _email = val),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            contentPadding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          ),
        ));
  }
}
