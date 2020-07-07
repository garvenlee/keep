import 'package:flutter/material.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:keep/data/provider/todoTag_provider.dart';
import 'package:provider/provider.dart';
import 'package:keep/models/todo.dart';

class TodoTagField extends StatefulWidget {
  final Todo todo;
  TodoTagField({Key key, @required this.todo}) : super(key: key);

  @override
  _TodoTagFieldState createState() => _TodoTagFieldState();
}

class _TodoTagFieldState extends State<TodoTagField> {
  List<Tar> selections;
  // String preTag;

  @override
  void initState() {
    super.initState();
    selections = widget.todo.tag
        .asMap()
        .map((idx, tag) => MapEntry(idx, Tar(name: tag, position: idx)))
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Todo>(
        builder: (context, todo, child) => FlutterTagging<Tar>(
            initialItems: selections,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.green.withAlpha(30),
                  // hintText: 'Search Tags',
                  labelText: 'Select Tags',
                  labelStyle: TextStyle(color: Colors.greenAccent)),
            ),
            findSuggestions: TarService.getTar,
            additionCallback: (value) {
              // setState(() => preTag = value);
              // print('whern ===============>');
              return Tar(
                name: value,
                position: 0,
              );
            },
            onAdded: (tag) {
              print('adding ================>');
              todo.tag = List<String>.from(todo.tag)..add(tag.name);
              TodoTagProvider().addTag([tag.name]);
              return Tar(
                  name: tag.name, position: TodoTagProvider().tags.length - 1);
            },
            configureSuggestion: (val) {
              print('suggestion===============>');
              return SuggestionConfiguration(
                leading: Icon(Icons.label),
                title: Text(val.name),
                // subtitle: Text(lang.position.toString()),
                additionWidget: Chip(
                  avatar: Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  ),
                  label: Text('Add New Tag'),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            configureChip: (tag) {
              return ChipConfiguration(
                label: Text(tag.name),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
                deleteIconColor: Colors.white,
              );
            },
            onChanged: () {
              print('onchanged');
            }));
  }
}

class Tar extends Taggable {
  final String name;
  final num position;

  Tar({this.name, this.position});
  @override
  List<Object> get props => [name];
  String toJson() => '''  {
    "name": $name,\n
    "position": $position\n
  }''';
}

List<Tar> toTar(Todo todo) {
  List<Tar> tar;
  for (var item in todo.tag) {
    var tmp = Tar(name: item, position: 0);
    tar.add(tmp);
  }
  return tar;
}

/// LanguageService
class TarService {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Tar>> getTar(String query) async {
    print('query is $query');
    await Future.delayed(Duration(milliseconds: 500), null);
    return TodoTagProvider()
        .tags
        .asMap()
        .map((position, tag) =>
            MapEntry(position, Tar(name: tag, position: position)))
        .values
        .toList()
        .where((val) => val.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

// tag 默认标签的显示和tag的过滤
class TagSearchService {
  static Future<List> getSuggestions(String query) async {
    await Future.delayed(Duration(milliseconds: 400), null);
    List<dynamic> tagList = TodoTagProvider().tags;
    List<dynamic> filteredTagList = <dynamic>[];
    if (query.isNotEmpty) {
      filteredTagList.add({'name': query, 'value': 0});
    }
    for (var tag in tagList) {
      if (tag['name'].toLowerCase().contains(query)) {
        filteredTagList.add(tag);
      }
    }
    return filteredTagList;
  }
}
