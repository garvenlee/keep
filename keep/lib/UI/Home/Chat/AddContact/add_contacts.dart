import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:keep/UI/Home/Chat/ChatScreenUI/chatscreen.dart';
import 'package:keep/data/provider/friend_provider.dart';
import 'package:keep/models/friend.dart';
// import 'package:keep/models/friend.dart';
// import 'package:keep/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:keep/data/provider/user_provider.dart';
// import 'package:keep/widget/component_widget.dart';
import 'package:keep/widget/user_pic.dart';
import 'package:keep/utils/reg_expression.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/service/socket_util.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:keep/models/recent_contacts.dart';
import 'package:keep/data/repository/recent_contacts_repository.dart';

class AddContactsPage extends StatefulWidget {
  final BuildContext context;
  AddContactsPage({this.context, Key key}) : super(key: key);

  @override
  _AddContactsPageState createState() => _AddContactsPageState();
}

class _AddContactsPageState extends State<AddContactsPage>
    with TickerProviderStateMixin {
  final int userOneId = UserProvider.getUserId();
  final String username = UserProvider().username;
  final Object avatar = UserProvider().userAvatar;
  BuildContext _ctx;
  bool _isLoading = false;

  String _firstname;
  String _lastname;
  String _pickname;
  String _email;
  String _phone;
  // RestDatasource _api = new RestDatasource();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final rcRepo = new RecentContactRepository();
  SocketIO _socket;

  Future _addContact(stream) async {
    await Navigator.pushNamed(_ctx, "/userProfile",
            arguments: {'user': stream['userTwo'], 'pickname': _pickname})
        .then((action) {
      if (action) {
        showHintText('add friend successfully.');
        final contact = RecentContact(
            userOneId: userOneId,
            userTwoId: stream['userTwo']['userId'],
            userTwoEmail: stream['userTwo']['email'],
            userTwoUsername: stream['userTwo']['username'],
            userTwoAvatarData: stream['userTwo']['avatar'],
            userTwoPickname: _pickname,
            lastSeenTime: DateTime.now().millisecondsSinceEpoch,
            isFriend: 1);
        final friend = Friend(
            username: stream['userTwo']['username'],
            email: stream['userTwo']['email'],
            userId: stream['userTwo']['userId'],
            base64Text: stream['userTwo']['avatar'],
            pickname: _pickname);
        rcRepo.newRContact(contact);
        FriendProvider.addFriend(friend);
        Navigator.pop(_ctx);
        Navigator.of(widget.context).push(new MaterialPageRoute(builder: (_) {
          return ChatScreen(userType: 1, friend: friend, messages: []);
        }));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initSocket().then((socket) {
      _socket = socket;
      _socket.on('friendRequestAck', (stream) {
        if (stream['status'] == 200) {
          _addContact(stream);
        } else if (stream['status'] == 404) {
          print('status： 404');
          // showHintText('Please check out, user ' + _email + ' does not exist!');
          _showSnackBar(
              'Please check out, user ' + _email + ' does not exist!');
        } else if (stream['status'] == 403) {
          print('status: 403');
          // showHintText('Sorry, Email and Phone do not match.');
          _showSnackBar('Sorry, Email and Phone do not match.');
        } else {
          // showHintText('Sorry, come out an error.');
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

  void _submit(connectionStatus) {
    final form = _formKey.currentState;
    // print('enter...');
    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      if (_lastname.isNotEmpty)
        _pickname = _firstname + ' ' + capitalize(_lastname);
      else
        _pickname = _firstname;
      if (FriendProvider.isExist(_email)) {
        _showSnackBar(_email + ' has been your friend.');
      } else {
        if (connectionStatus == ConnectivityStatus.Available) {
          // print(pickname);
          _socket.emit('friendRequest', [
            {"userOneId": userOneId, "twoEmail": _email, "phone": _phone}
          ]);
          // _showSnackBar('Friend request has been sent successfully!');
        } else {
          _showSnackBar('Please check your internet.');
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
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
    return GestureDetector(
        onTap: () => _unfocus(),
        child: new Scaffold(
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
                  buildPhoneField(),
                ])))));
  }

  Widget buildHeader() {
    return Consumer<ConnectivityStatus>(
        builder: (context, connectionStatus, _) {
      String headerText;
      if (connectionStatus == ConnectivityStatus.Available)
        headerText = 'Add Contacts';
      else
        headerText = 'Connecting...';
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
                        icon: Icon(Icons.done),
                        onPressed: () => _submit(connectionStatus))),
          ]));
    });
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

  Widget buildPhoneField() {
    return Container(
        margin: EdgeInsets.only(top: 8.0),
        width: MediaQuery.of(_ctx).size.width - 24.0 - 32.0,
        // height: 40.0,
        child: TextFormField(
          validator: null,
          onSaved: (val) => setState(() => _phone = val),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Phone',
            labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            contentPadding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          ),
        ));
  }
}
