import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_note/src/db_helper/db_helper.dart';
import 'package:lets_note/src/models/notes.dart';
import 'package:lets_note/src/screens/note_detail.dart';
import 'package:lets_note/src/screens/note_search.dart';
import 'package:lets_note/src/widgets/color_picker.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  int axisCount = 2;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: customAppBar(),
      body: noteList.length == 0
          ? Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                      'If you give people nothingness, they can ponder what can be achieved from that nothingness.',
                      style: Theme.of(context).textTheme.bodyText2),
                ),
              ),
            )
          : Container(
              color: Colors.white,
              child: getNotesList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 0), 'Add Note');
        },
        tooltip: 'Add Note',
        shape: CircleBorder(side: BorderSide(color: Colors.black, width: 2.0)),
        child: FaIcon(
          FontAwesomeIcons.plus,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget getNotesList() {
    return StaggeredGridView.countBuilder(
      physics: BouncingScrollPhysics(),
      crossAxisCount: 4,
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => GestureDetector(
        onTap: () {
          navigateToDetail(this.noteList[index], 'Edit Note');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: colors[this.noteList[index].color],
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          this.noteList[index].title,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                            this.noteList[index].description == null
                                ? ''
                                : this.noteList[index].description,
                            style: Theme.of(context).textTheme.bodyText1),
                      )
                    ],
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(this.noteList[index].date,
                          style: Theme.of(context).textTheme.subtitle2),
                    ])
              ],
            ),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
    );
  }

  Widget customAppBar() {
    return AppBar(
      title: Text('Notes', style: Theme.of(context).textTheme.headline5),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: noteList.length == 0
          ? Container()
          : IconButton(
              icon: FaIcon(
                FontAwesomeIcons.search,
                color: Colors.black,
              ),
              onPressed: () async {
                final Note result = await showSearch(
                    context: context, delegate: NotesSearch(notes: noteList));
                if (result != null) {
                  navigateToDetail(result, 'Edit Note');
                }
              },
            ),
      actions: <Widget>[
        noteList.length == 0
            ? Container()
            : IconButton(
                icon: Icon(
                  axisCount == 2 ? FontAwesomeIcons.listAlt : FontAwesomeIcons.th,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    axisCount = axisCount == 2 ? 4 : 2;
                  });
                },
              )
      ],
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
