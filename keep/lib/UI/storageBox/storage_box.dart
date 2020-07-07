import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:keep/widget/search_header.dart';

// ignore: prefer_collection_literals
final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
      }),
].toSet();

class StorageBox extends StatefulWidget {
  final String url;
  StorageBox({Key key, this.url}) : super(key: key);

  @override
  _StorageBoxState createState() => _StorageBoxState();
}

class _StorageBoxState extends State<StorageBox> {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  String dropdownValue = 'One';
  var _searchController = new TextEditingController();
  var _focusNode = new FocusNode();

  @override
  void dispose() {
    // print('closing....................');
    flutterWebViewPlugin.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      child: WebviewScaffold(
        url: widget.url,
        javascriptChannels: jsChannels,
        mediaPlaybackRequiresUserGesture: false,
        withZoom: true,
        appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 50.0),
            child: buildSearchHeader(context, _searchController, _focusNode)),
        withLocalStorage: true,
        hidden: true,
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  flutterWebViewPlugin.goBack();
                },
              ),
              IconButton(
                icon: const Icon(Icons.autorenew),
                onPressed: () {
                  flutterWebViewPlugin.reload();
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  flutterWebViewPlugin.goForward();
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
