import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keep/utils/utils_class.dart';
import 'package:keep/utils/util_bloc.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:keep/utils/reg_expression.dart' show judgeUrl;
import 'package:keep/data/provider/panelAcrion_provider.dart'
    show StoragePanelAction;

class StoragePanel extends StatelessWidget {
  final TextEditingController textEditingController;
  const StoragePanel({Key key, @required this.textEditingController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ClipBoardData, StoragePanelAction>(
        builder: (context, clipboard, panelAction, child) {
      if (clipboard != null &&
          clipboard.text.isNotEmpty &&
          judgeUrl(clipboard.text)) {
        return Positioned.fill(
          bottom: panelAction.enterTag
              ? MediaQuery.of(context).size.height * 0.5 - 50
              : 20,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                // color: Colors.greenAccent,
                // alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  border: Border.all(
                    width: 0.2,
                    color: Colors.grey,
                    style: BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 1.2,
                      spreadRadius: 0.0,
                      offset:
                          Offset(0.5, 0.5), // shadow direction: bottom right
                    )
                  ],
                ),
                height: 90.0,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              clipboardBloc.clear().then((_) {
                                if (panelAction.enterTag)
                                  panelAction.enterTag = false;
                              });
                            })),
                    Flexible(
                        flex: 7,
                        fit: FlexFit.tight,
                        child: buildActionSection(
                            clipboard.text, panelAction.enterTag)),
                    Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Container(
                            // width: MediaQuery.of(context).size.width * 0.3,
                            child: FlatButton(
                                onPressed: () {
                                  if (!panelAction.enterTag) {
                                    panelAction.enterTag = true;
                                  } else {
                                    clipboardBloc.clear().then((_) {
                                      panelAction.enterTag = false;
                                      showHintText(
                                          "add collection successfully.");
                                    });
                                    print(
                                        'url is ${textEditingController.text}');
                                    handleURL(clipboard.text,
                                        textEditingController.text);
                                    textEditingController.clear();
                                  }
                                },
                                child: Text(
                                  panelAction.enterTag ? 'Save' : 'Add Tag',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: 'Roboto',
                                  ),
                                ))))
                  ],
                ),
              )),
        );
      } else
        return Container();
    });
  }

  Widget buildActionSection(snapshotData, bool enterTag) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: enterTag
            ? TextField(
                maxLength: 150,
                autofocus: true,
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: "Input New Tag",
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Copied Url?',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    snapshotData,
                    style: TextStyle(fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ));
  }
}
