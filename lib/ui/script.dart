import 'dart:async';

import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

import '/model/user_note.dart';
import '/service/text_to_speech.dart';
import '/util/textmap.dart';
import '/util/util.dart';
import 'edit.dart';
import 'menudrawer.dart';
import 'saveform.dart';
import 'view_notes_detail.dart';

///Script file
class Script extends StatelessWidget {
  ///Log
  final UserNote userNote;

  ///Date: Date of this note.
  final String date;

  ///Time: Time of this note.
  final String time;

  ///logMap: Map of all saved notes for deleting/editing.
  final Map logMap;

  ///textSize: Size of text for the script page.
  final double textSize;

  final _tts = TextToSpeech();
  final TextMap _logs = TextMap();

  ///Script to read
  Script(
      {Key key,
      @required this.userNote,
      @required this.date,
      @required this.time,
      @required this.textSize,
      this.logMap})
      : super(key: key);

  void _deleteButtonPressed(BuildContext context) async {
    await _logs.deleteLog(date, time);

    Timer.run(() async {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  ViewNotesDetail(filterFavorite: userNote.isFavorite)),
          (route) => false);
    });
  }

  void _addButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveForm()),
    );
  }

  void _editButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Edit(
              userNote: userNote,
              date: date,
              time: time,
              textSize: (textSize / 2))),
    );
  }

  void _favoriteButtonPressed(BuildContext context) async {
    userNote.isFavorite = !userNote.isFavorite;
    await _logs.changeLog(date, time, userNote);
    (context as Element).markNeedsBuild();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text("Note"),
      ),
      endDrawer: MenuDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$date at ${time.substring(0, 5)}",
              style: TextStyle(
                  fontSize: textSize,
                  color: Colors.indigo,
                  decoration: TextDecoration.underline)),
          SizedBox(
            height: 5,
          ),
          SingleChildScrollView(
              padding: EdgeInsets.all(12.0),
              child: TextHighlight(
                text: userNote.note.trim(),
                words: highlights,
                textStyle: TextStyle(
                    fontSize: textSize,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              )),
          SizedBox(
              width: 400,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewNotesDetail(
                            filterFavorite: userNote.isFavorite)),
                  );
                },
                child: Text("Back",
                    style: TextStyle(
                      fontSize: 16,
                    )),
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addButtonPressed(context);
        },
        tooltip: "Centre FAB",
        child: Container(
          margin: EdgeInsets.all(15.0),
          child: Icon(Icons.add),
        ),
        elevation: 4.0,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  _tts.speak(userNote.note);
                },
                iconSize: 30.0,
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.indigo,
                ),
              ),
              IconButton(
                onPressed: () {
                  _favoriteButtonPressed(context);
                },
                iconSize: 30.0,
                icon: Icon(
                  userNote != null && userNote.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(
                width: 50.0,
              ),
              IconButton(
                onPressed: () {
                  _deleteButtonPressed(context);
                },
                iconSize: 30.0,
                icon: Icon(
                  Icons.delete,
                  color: Colors.indigo,
                ),
              ),
              IconButton(
                onPressed: () {
                  _editButtonPressed(context);
                },
                iconSize: 30.0,
                icon: Icon(
                  Icons.edit,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
        //to add a space between the FAB and BottomAppBar
        shape: CircularNotchedRectangle(),
        //color of the BottomAppBar
        color: Colors.white,
      ),
    );
  }
}
