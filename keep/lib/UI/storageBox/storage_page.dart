import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:keep/BLoC/storage_bloc.dart';
import 'package:keep/UI/storageBox/storage_box.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:keep/widget/storage_panel_widget.dart';
import 'package:keep/models/storageUrl.dart';
import 'package:keep/widget/custom_overlay.dart';

class StoragePage extends StatefulWidget {
  StoragePage({Key key}) : super(key: key);

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final textController = new TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          StorageView(),
          StoragePanel(textEditingController: textController)
        ],
      ),
    );
  }
}

class StorageView extends StatelessWidget {
  final CollectionBloc collectionBloc = new CollectionBloc();

  // StorageView(this.collectionBloc);
  final DismissDirection _dismissDirection = DismissDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => collectionBloc,
        dispose: (context, bloc) => bloc.dispose(),
        child: Material(
            child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('Collections'),
            backgroundColor: Colors.cyan,
            elevation: 5.0,
          ),
          body: StreamBuilder(
            stream: collectionBloc.collections,
            builder: (BuildContext context,
                AsyncSnapshot<List<StorageUrl>> snapshot) {
              if (snapshot.hasData && snapshot.data.length > 0) {
                // print(snapshot.data);
                print('reload the list view ===================>');
                return buildListView(context, snapshot.data);
              } else {
                return Container();
              }
            },
          ),
        )));
  }

  buildListView(BuildContext context, List<StorageUrl> collections) {
    Widget redDivider = Divider(color: Colors.red, indent: 16, endIndent: 16);
    Widget blueDivider = Divider(color: Colors.blue, indent: 16, endIndent: 16);
    return Container(
        child: ClipRect(
            // Forces the OverlayEntry not to overflow this container
            child: Overlay(
                // The Overlay that allows us to control the positioning
                initialEntries: <OverlayEntry>[
          OverlayEntry(
              builder: (BuildContext context) => Scrollbar(
                  child: ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) {
                        return index % 2 == 0 ? redDivider : blueDivider;
                      },
                      itemCount: collections.length,
                      itemBuilder: (BuildContext context, int index) {
                        StorageUrl coll = collections[index];
                        List<String> tags = coll.tags;
                        print('reload the list view ===============>');
                        return OverlayableContainerOnLongPress(
                          child: Dismissible(
                            key: UniqueKey(),
                            direction: _dismissDirection,
                            background: Container(
                                color: Colors.redAccent,
                                padding: EdgeInsets.only(left: 10, right: 10.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.delete),
                                      Text("Delete",
                                          style: TextStyle(color: Colors.black))
                                    ])),
                            onDismissed: (direction) => collectionBloc
                                .deleteCollection(coll.createAt)
                                .then((_) => collectionBloc.getCollections()),
                            child: ListTile(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(builder: (_) {
                                    return StorageBox(url: coll.url);
                                  }));
                                },
                                title: Container(
                                    padding: EdgeInsets.only(bottom: 5.0),
                                    child: Text(coll.title,
                                        style: TextStyle(fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                subtitle: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                        height: 20,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: tags.length,
                                            itemBuilder: (context, index) =>
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 5.0),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                                  decoration: BoxDecoration(
                                                    // color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    border: Border.all(
                                                        color: Colors.grey
                                                            .withGreen(164)),
                                                  ),
                                                  child: Center(
                                                      child: Text(tags[index],
                                                          style: TextStyle(
                                                              fontSize: 12))),
                                                )))),
                                trailing: Container(
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Color(0xFF9E9E9E), // 底色
                                    ),
                                    // margin: EdgeInsets.symmetric(vertical: 8.0),
                                    child: coll.avatar != 'null'
                                        ? Container(
                                            width: 80.0,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: txt2Image(coll.avatar,
                                                      scale: 2.0)),
                                            ))
                                        : SizedBox(
                                            width: 80.0,
                                            height: 80,
                                            child: Center(
                                              child: Text('loading'),
                                            )))),
                          ),
                          overlayContentBuilder: (BuildContext context,
                              VoidCallback onHideOverlay) {
                            return Container(
                              height: double.infinity,
                              color: Colors.black38,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  IconButton(
                                    icon:
                                        FaIcon(FontAwesomeIcons.firefoxBrowser),
                                    onPressed: () {
                                      onHideOverlay();
                                      _onShowInBroswer(coll.url);
                                    },
                                  ),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.link),
                                    onPressed: () {
                                      onHideOverlay();
                                      _onWebViewItem(coll.url);
                                    },
                                  ),
                                  IconButton(
                                    icon: FaIcon(FontAwesomeIcons.inbox),
                                    color: Colors.black,
                                    onPressed: () => _onAppView(coll.url),
                                  )
                                ],
                              ),
                            );
                          },
                          onTap: () => debugPrint('trigger webview.'),
                        );
                      })))
        ])));
  }

  void _onAppView(url) async {
    print('app view: $url');
    // launchInWebViewOrVC(url);
    launchInWebViewWithDomStorage(url)
        .catchError((_) => showHintText('unknown error'));
    // launchInWebViewWithJavaScript(url);
  }

  void _onShowInBroswer(url) async {
    print('show in broswer: $url');
    launchInBrowser(url).catchError((_) => showHintText('unknown error'));
  }

  void _onWebViewItem(url) async {
    print('web view: $url ');
    launchUniversalLinkIos(url)
        .catchError((_) => showHintText('unknown error'));
    // launchInWebViewWithDomStorage(url);
  }
}
