import 'dart:async';
import 'package:keep/data/sputil.dart';
import 'package:keep/utils/event_util.dart';
import 'package:keep/utils/tools_function.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:keep/settings/icons.dart';
import 'package:keep/settings/styles.dart';
import 'package:keep/models/filter.dart';
import 'package:keep/models/note.dart';
import 'package:keep/BLoC/note_bloc.dart';
import 'package:keep/data/provider/user_provider.dart';
import 'package:keep/data/provider/noteTag_provider.dart' show NoteTagProvider;
import 'package:keep/utils/platform_utils.dart';
// import 'package:keep/utils/event_util.dart';
import 'package:keep/utils/utils_class.dart' show ConnectivityStatus;
import 'package:keep/utils/notes_service.dart' show CommandHandler;
import 'package:keep/widget/over_scroll.dart';
import 'package:keep/widget/drawer_filter.dart';
import 'package:keep/widget/notes_grid.dart';
import 'package:keep/widget/notes_list.dart';
import 'note_presenter.dart';

/// Home screen, displays [Note] grid or list.
class NotePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NotePageState();
}

/// [State] of [NotePage].
class NotePageState extends State<NotePage>
    with CommandHandler
    implements NoteScratchContract {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NoteFilter _noteFilter;
  final bloc = new NoteBloc();

  static int _userId = UserProvider.getUserId();

  // Get our connection status from the provider
  BuildContext _ctx;
  int noteNum = 0;
  bool updateFlag = false;

  // pull_refresh
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  NoteScratchPresenter _presenter;

  NotePageState() {
    _presenter = new NoteScratchPresenter(this);
  }

  @override
  void initState() {
    super.initState();
    _noteFilter = NoteFilter(
        NoteState.values[SpUtil.getInt('noteFilter-$_userId', defValue: 0)]);
  }

  void _onRefresh(connectionStatus) async {
    // monitor network fetch
    if (connectionStatus == ConnectivityStatus.Available) {
      // await Future.delayed(Duration(milliseconds: 3000));
      print('onRefreshing===================>');
      bloc
          .getNotSyncNotes()
          .then((notes) => _presenter.syncNotes(_userId, notes));
    } else {
      await Future.delayed(Duration(milliseconds: 1000));
      _refreshController.refreshFailed();
    }
  }

  void onScratchSuccess(List<Note> notes) {
    bloc.checkNoteState(notes).then((_) {
      showHintText('sync successfully.');
      _refreshController.refreshCompleted();
      setState(() => updateFlag = !updateFlag);
      // bloc.getNotes();
    });
  }

  void onScratchError(String errorTxt) {
    showHintText('unknown error.');
    _refreshController.refreshToIdle();
  }

  void _unfocus() {
    Provider.of<NoteFilter>(_ctx).showPanel = false;
  }

  /// Create notes query
  Stream<List<Note>> _createNoteStream(
      NoteFilter filter, NoteTagProvider noteTag) {
    final String tag = noteTag.selectionTag;
    final String whereString = filter.noteState == NoteState.unspecified
        ? (tag == null ? 'state < ?' : 'state < ? and tag = ?')
        : (tag == null ? 'state = ?' : 'state = ? and tag = ?');
    final query = filter.noteState == NoteState.unspecified
        ? (tag == null
            ? [NoteState.archived.index.toString()]
            : [NoteState.archived.index.toString(), tag])
        : (tag == null
            ? [filter.noteState.index.toString()]
            : [filter.noteState.index.toString(), tag]);
    final bloc = NoteBloc(whereString: whereString, query: query);
    return bloc.notes;
  }

  Widget _fab(BuildContext context) => FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final command = await Navigator.pushNamed(context, '/note',
              arguments: {'uid': _userId});
          debugPrint('--- noteEditor result: $command');
          // processNoteCommand(_scaffoldKey.currentState, command);
          if (processStreamLoad(command)) {
            debugPrint('detect new note................');
            Future.delayed(Duration(milliseconds: 700),
                () => setState(() => noteNum += 1));
            bus.emit('addId', noteNum);
          }
        },
      );

  /// Callback on a single note clicked
  void _onNoteTap(Note note) async {
    final command = await Navigator.pushNamed(_ctx, '/note',
        arguments: {'note': note, 'uid': _userId});
    processNoteCommand(_scaffoldKey.currentState, command).then((_) {
      if (processStreamLoad(command)) {
        debugPrint('modify the note.....');
        Future.delayed(Duration(milliseconds: 700),
            () => setState(() => updateFlag = !updateFlag));
      }
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    bus.off('note_page_update');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    bus.on('note_page_update', (_) => setState(() => updateFlag = !updateFlag));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => _noteFilter),
          ChangeNotifierProvider(create: (_) => NoteTagProvider()),
          // Consumer2<NoteFilter, NoteTagProvider>(
          //   builder: (context, filter, noteTag, child) => StreamProvider(
          //     // updateShouldNotify: (_, __) => true,
          //     updateShouldNotify: (pre, next) => pre?.length != next?.length,
          //     create: (context) => _createNoteStream(filter, noteTag),
          //     child: child))
        ],
        // child: Consumer3<NoteFilter, NoteTagProvider, List<Note>>(
        //   builder: (context, filter, noteTag, notes, child){
        //         final hasNotes = notes?.isNotEmpty == true;
        //         final canCreate = filter.noteState.canCreate;
        //         // noteNum = hasNotes ? notes.length : 0;
        //         debugPrint('note num is $noteNum');
        //         return Stack(children: <Widget>[
        //           buildNoteView(context, notes, filter, hasNotes, canCreate),
        //           buildSlidePanel(context, filter, noteTag)
        //         ]);
        //   },
        // )
        child: Consumer2<NoteFilter, NoteTagProvider>(
          builder: (context, filter, noteTag, child) {
            debugPrint('reload the whole page.....');
            final stream = _createNoteStream(filter, noteTag);
            return StreamBuilder(
              stream: stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                final notes = snapshot.data;
                final hasNotes = notes?.isNotEmpty == true;
                final canCreate = filter.noteState.canCreate;
                noteNum = hasNotes ? notes.length : 0;
                debugPrint('note num is $noteNum');
                return Stack(children: <Widget>[
                  buildNoteView(context, notes, filter, hasNotes, canCreate),
                  buildSlidePanel(context, filter, noteTag)
                ]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildNoteView(context, notes, filter, hasNotes, canCreate) {
    return GestureDetector(
        onTap: () => filter.showPanel = false,
        child: Scaffold(
          key: _scaffoldKey,
          body: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: 720),
                  child: ScrollConfiguration(
                    behavior: OverScrollBehavior(),
                    child: Consumer<ConnectivityStatus>(
                        builder: (context, connectionStatus, child) =>
                            SmartRefresher(
                                enablePullDown: true,
                                // enablePullUp: true,
                                header: WaterDropHeader(),
                                controller: _refreshController,
                                onRefresh: () => _onRefresh(connectionStatus),
                                // onLoading: _onLoading,
                                child: child),
                        child: CustomScrollView(
                          slivers: <Widget>[
                            if (filter.noteState.index >=
                                NoteState.archived.index)
                              SliverAppBar(
                                floating: true,
                                snap: true,
                                title: _topActions(
                                    context, filter.noteState, filter.gridView),
                                automaticallyImplyLeading: false,
                                centerTitle: true,
                                titleSpacing: 0,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                            if (hasNotes)
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ..._buildNotesView(context, filter, notes),
                            if (hasNotes)
                              SliverToBoxAdapter(
                                child: SizedBox(
                                    height:
                                        (canCreate ? kBottomBarSize : 10.0) +
                                            10.0),
                              ),
                          ],
                        )),
                  ))),
          floatingActionButton: canCreate ? _fab(context) : null,
          bottomNavigationBar: canCreate
              ? _bottomActions(context, filter.noteState, filter.gridView)
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          extendBody: true,
        ));
  }

  Widget buildSlidePanel(context, filter, noteTag) {
    final showPanel = filter.showPanel;
    return GestureDetector(
        onTap: () => _unfocus(),
        onVerticalDragCancel: () => filter.showPanel = false,
        child: SlidingUpPanel(
            maxHeight: MediaQuery.of(context).size.height * .60,
            minHeight: showPanel ? kBottomBarSize + 136.0 : 0,
            parallaxEnabled: true,
            parallaxOffset: .5,
            panel: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                    constraints: BoxConstraints(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(top: 12.0, bottom: 4.0),
                              height: 5.0,
                              width: 64.0,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(3.0))),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 8),
                              DrawerFilterItem(
                                  icon: AppIcons.thumbtack,
                                  title: 'Notes',
                                  isChecked:
                                      filter.noteState == NoteState.unspecified,
                                  onTap: () =>
                                      filter.noteState = NoteState.unspecified),
                              DrawerFilterItem(
                                  icon: AppIcons.archive_outlined,
                                  title: 'Archive',
                                  isChecked:
                                      filter.noteState == NoteState.archived,
                                  onTap: () =>
                                      filter.noteState = NoteState.archived),
                              DrawerFilterItem(
                                  icon: AppIcons.delete_outline,
                                  title: 'Trash',
                                  isChecked:
                                      filter.noteState == NoteState.deleted,
                                  onTap: () =>
                                      filter.noteState = NoteState.deleted),
                              const SizedBox(height: 16),
                              const Divider(
                                height: 1,
                              ),
                              SingleChildScrollView(
                                  physics:
                                      // NeverScrollableScrollPhysics(),
                                      AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxHeight: 300.0),
                                      child: ScrollConfiguration(
                                          behavior: OverScrollBehavior(),
                                          child: ListView.builder(
                                            // physics: AlwaysScrollableScrollPhysics(),
                                            itemCount: noteTag.tags.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final isChecked =
                                                  noteTag.selectionId == index;
                                              return DrawerFilterItem(
                                                icon: AppIcons.label,
                                                title: noteTag.tags[index],
                                                isChecked: isChecked,
                                                onTap: () {
                                                  filter.showPanel = false;
                                                  if (isChecked)
                                                    Provider.of<NoteTagProvider>(
                                                            context,
                                                            listen: false)
                                                        .setSelectionId(-1);
                                                  else
                                                    Provider.of<NoteTagProvider>(
                                                            context,
                                                            listen: false)
                                                        .setSelectionId(index);
                                                },
                                              );
                                            },
                                          )))),
                            ],
                          )
                        ])))));
  }

  Widget _topActions(BuildContext context, NoteState state, bool gridView) =>
      Container(
        // width: double.infinity,
        constraints: const BoxConstraints(
          maxWidth: 720,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Icon(
                      noteIcon[state.index],
                      color: kIconTintLight,
                    ),
                    onTap: () => Provider.of<NoteFilter>(context, listen: false)
                        .setPanel()),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Search your notes',
                    softWrap: false,
                    style: TextStyle(
                      color: kHintTextColorLight,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (state == NoteState.archived)
                  InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Icon(
                        gridView ? AppIcons.view_list : AppIcons.view_grid,
                        color: kIconTintLight,
                      ),
                      onTap: () =>
                          Provider.of<NoteFilter>(context, listen: false)
                              .setView()),
                if (state == NoteState.deleted)
                  InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Icon(
                        Icons.clear_all,
                        color: kIconTintLight,
                      ),
                      onTap: () => bloc.deleteAllTrash().then(
                          (_) => setState(() => updateFlag = !updateFlag))),
                const SizedBox(width: 18),
              ],
            ),
          ),
        ),
      );

  Widget _bottomActions(BuildContext context, NoteState state, bool gridView) =>
      BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: kBottomBarSize,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const SizedBox(width: 20),
              InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(
                    noteIcon[state.index],
                    size: 26,
                    color: kIconTintLight,
                  ),
                  onTap: () => Provider.of<NoteFilter>(context, listen: false)
                      .showPanel = true),
              const SizedBox(width: 30),
              const Icon(AppIcons.brush_sharp, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.mic, size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              const Icon(AppIcons.insert_photo,
                  size: 26, color: kIconTintLight),
              const SizedBox(width: 30),
              InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Icon(
                    gridView ? AppIcons.view_list : AppIcons.view_grid,
                    size: 26,
                    color: kIconTintLight,
                  ),
                  onTap: () =>
                      Provider.of<NoteFilter>(context, listen: false).setView())
            ],
          ),
        ),
      );

  /// A grid/list view to display notes
  ///
  /// Notes are divided to `Pinned` and `Others` when there's no filter,
  /// and a blank view will be rendered, if no note found.
  List<Widget> _buildNotesView(
      BuildContext context, NoteFilter filter, List<Note> notes) {
    if (notes?.isNotEmpty != true) {
      // print('building blank view..............');
      return [_buildBlankView(filter.noteState)];
    }

    final asGrid = filter.noteState == NoteState.deleted || filter.gridView;
    final factory = asGrid ? NotesGrid.create : NotesList.create;
    final showPinned = filter.noteState == NoteState.unspecified;

    if (!showPinned) {
      return [
        factory(notes: notes, onTap: _onNoteTap),
      ];
    }

    final partition = _partitionNotes(notes);
    final hasPinned = partition.item1.isNotEmpty;
    final hasUnpinned = partition.item2.isNotEmpty;
    final stateId =
        hasUnpinned ? NoteState.unspecified.index : filter.noteState.index;
    final _buildLabel = (String label, [double top = 26]) => SliverToBoxAdapter(
          child: Container(
            padding:
                EdgeInsetsDirectional.only(start: 26, bottom: 25, top: top),
            child: Text(
              label,
              style: const TextStyle(
                  color: kHintTextColorLight,
                  fontWeight: FontWeights.medium,
                  fontSize: 12),
            ),
          ),
        );
    return [
      if (hasPinned) _buildLabel('PINNED', 0),
      if (hasPinned)
        factory(
            notes: partition.item1,
            onTap: _onNoteTap,
            stateId: NoteState.pinned.index),
      if (hasPinned && hasUnpinned) _buildLabel('OTHERS'),
      factory(notes: partition.item2, onTap: _onNoteTap, stateId: stateId)
    ];
  }

  Widget _buildBlankView(NoteState filteredState) => SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Expanded(flex: 1, child: SizedBox()),
            Icon(
              AppIcons.thumbtack,
              size: 120,
              color: kAccentColorLight.shade300,
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'hey',
                style: TextStyle(
                  color: kHintTextColorLight,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );

  /// Partition the note list by the pinned state
  Tuple2<List<Note>, List<Note>> _partitionNotes(List<Note> notes) {
    if (notes?.isNotEmpty != true) {
      return Tuple2([], []);
    }

    final indexUnpinned = notes?.indexWhere((n) => !n.pinned);
    return indexUnpinned > -1
        ? Tuple2(notes.sublist(0, indexUnpinned), notes.sublist(indexUnpinned))
        : Tuple2(notes, []);
  }
}
