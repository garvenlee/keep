import 'package:flutter/material.dart';

class SearchRegion extends StatefulWidget {
  SearchRegion(
    this.searchController,
    this.focusNode
  );
  final TextEditingController searchController;
  final FocusNode focusNode;
  @override
  _SearchRegionState createState() => new _SearchRegionState();
}

class _SearchRegionState extends State<SearchRegion> {
  Widget searchWrap;
  bool clickBtn = false;

  @override
  Widget build(BuildContext context) {
    if (this.clickBtn) {
      return Row(children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(2.0),
            child: Container(
                height: 40.0,
                child: Center(
                    child: TextField(
                        maxLines: 1,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            hintText: "Search",
                            hintStyle: TextStyle(fontSize: 16.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none)),
                        controller: widget.searchController,
                        onChanged: (String text) {
                          setState(() => {});
                        },
                        // onSubmitted: (val) => _handleSubmitted,
                        onEditingComplete: () {
                          var value = widget.searchController.text;
                          print(value);
                          if (value != null && value != '') {
                            // SharedPreferences prefs = await SharedPreferences.getInstance();
                            // prefs.setString(
                            //     'searchList', prefs.getString('searchList') + ',' + value.toString());
                            // getSearchList();
                            print(value);
                            widget.searchController.clear();
                          }
                        })))),
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              widget.focusNode.unfocus();
              widget.searchController.clear();
              setState(() {
                this.clickBtn = !this.clickBtn;
              });
            }),
      ]);
    } else {
      return IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {
          setState(() {
            this.clickBtn = !this.clickBtn;
          });
        },
      );
    }
  }

//   void _handleSubmitted() {
//     print('get the text.....');
//     var value = widget.searchController.text;
//     // print(value);
//     if (value != null && value != '') {
//       // SharedPreferences prefs = await SharedPreferences.getInstance();
//       // prefs.setString(
//       //     'searchList', prefs.getString('searchList') + ',' + value.toString());
//       // getSearchList();
//       print(value);
//       widget.searchController.clear();
//     }
//   }
}


Widget buildSearchHeader(BuildContext context, TextEditingController _searchController, FocusNode _focusNode){
  return new Container(
                height: 50.0,
                decoration: BoxDecoration(color: Colors.blueGrey),
                padding: new EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          _focusNode.unfocus();
                          _searchController.clear();
                          Navigator.of(context).pop();
                        }),
                    SearchRegion(_searchController, _focusNode)
                  ],
                ));
}