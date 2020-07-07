import 'package:flutter/material.dart';
import 'package:keep/service/rest_ds.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/utils/reg_expression.dart';
import 'package:keep/widget/user_pic.dart';
// import 'package:keep/models/group.dart';
import 'package:keep/models/group_source.dart';
import 'package:provider/provider.dart';

class AddRoomPage extends StatefulWidget {
  final BuildContext context;
  AddRoomPage({Key key, @required this.context}) : super(key: key);
  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  var _focusNodeGroup = new FocusNode();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _api = new RestDatasource();
  final _textController = new TextEditingController();
  GroupSource _group;
  String _groupNum;
  bool errHint = false;
  BuildContext _ctx;
  bool _isLoading = false;

  void _submit(connectionStatus) {
    final form = _formKey.currentState;
    setState(() {
      _isLoading = true;
      _group = null;
      errHint = false;
    });
    if (form.validate()) {
      form.save();
      if (connectionStatus == ConnectivityStatus.Available) {
        print(_groupNum);
        _api.getGroupByNumber(_groupNum).then((GroupSource group) {
          setState(() {
            _isLoading = false;
            _group = group;
          });
          // print(_group.group);
          _unfocus();
          // print(group.roomId);
        }).catchError((err) {
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _isLoading = false;
              errHint = true;
            });
          });
          print(err.toString());
        });
      } else {
        debugPrint('no internet');
        _showSnackBar('no internet');
      }
    }
  }

  void _unfocus() {
    FocusScopeNode currentFocus = FocusScope.of(_ctx);
    if (!currentFocus.hasPrimaryFocus) {
      print('unfocus');
      currentFocus.unfocus();
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
        key: scaffoldKey,
        body: GestureDetector(
            onTap: () => _unfocus(),
            child: Material(
                child: ListView(
              children: [
                buildHeader(),
                buildForm(),
                if (_isLoading) buildLoading(),
                if (_group != null) buildGroupItem(),
                if (errHint) buildErrorHint(),
              ],
            ))));
  }

  Widget buildForm() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Form(
              key: _formKey,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.72,
                child: TextFormField(
                  autofocus: true,
                  focusNode: _focusNodeGroup,
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 10,
                  validator: (val) => judgeGroupNumber(val),
                  onSaved: (val) => _groupNum = val,
                  onTap: () => setState(() {
                    errHint = false;
                    _group = null;
                  }),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 5.0),
                    hintText: "Group Account",
                    hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey),
                  ),
                ),
              )),
          Consumer<ConnectivityStatus>(builder: (context, connectionStatus, _) {
            return IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.blueAccent,
              icon: Icon(Icons.search),
              onPressed: () => _submit(connectionStatus),
            );
          }),
        ]));
  }

  Widget buildGroupItem() {
    return new ListTile(
      onTap: () async => await Navigator.of(widget.context)
          .pushNamed('/groupProfile', arguments: {
        'group': _group.encodeStr()
      }).then((value) => Navigator.pop(_ctx)),
      leading: new Hero(
          tag: _group.group.roomId,
          child: _group.group.roomAvatar != 'null'
              ? CircleAvatar(backgroundImage: _group.group.roomAvatarObj)
              : normalUserPic(
                  username: _group.group.roomName,
                  picRadius: 25.0,
                  fontSize: 20.0,
                  fontColor: Colors.white,
                  bgColor: Colors.indigoAccent)),
      title: new Text(_group.group.roomName),
      subtitle: new Text(_group.group.roomNumber),
    );
  }

  Widget buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 3,
          semanticsValue: 'loading',
          semanticsLabel: 'loading',
        ),
        SizedBox(height: 15.0),
        Text(
          'loading...',
          style: TextStyle(fontSize: 14.0),
        )
      ],
    );
  }

  Widget buildErrorHint() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'there has not a group which number is ${_textController.text}')
          ],
        ));
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
          ]));
    });
  }
}
