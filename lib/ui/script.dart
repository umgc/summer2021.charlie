import 'dart:async';

import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

import '/service/text_to_speech.dart';
import '/util/util.dart';
import 'edit.dart';
import 'load.dart';
import 'menudrawer.dart';
import 'save.dart';
import 'textmap.dart';

///Script file
class Script extends StatelessWidget {
  ///Log: Text of this note.
  final String log;

  ///Date: Date of this note.
  final String date;

  ///Time: Time of this note.
  final String time;

  ///logMap: Map of all saved notes for deleting/editing.
  final Map logMap;

  final _tts = TextToSpeech();
  final TextMap _logs = TextMap();

  ///Script to read
  Script(
      {Key key,
      @required this.log,
      @required this.date,
      @required this.time,
      this.logMap})
      : super(key: key);

  void _deleteButtonPressed(BuildContext context) async {
    await _logs.deleteLog(date, time);

    Timer.run(() async {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Load()), (route) => false);
    });
  }

  void _addButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Save()),
    );
  }

  void _editButtonPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Edit(log: log, date: date, time: time)),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.view_headline_outlined,
          size: 40,
        ),
        title: Text("Note"),
      ),
      endDrawer: MenuDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$date at ${time.substring(0, 5)}"),
          TextHighlight(
            text: log,
            words: highlights,
            textStyle: const TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontWeight: FontWeight.w400),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Load()),
              );
            },
            child: Text("Back"),
          ),
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
                  _tts.speak(log);
                },
                iconSize: 30.0,
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.indigo,
                ),
              ),
              IconButton(
                onPressed: () {
                  //TODO favorite
                },
                iconSize: 30.0,
                icon: Icon(
                  Icons.favorite_outline,
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
