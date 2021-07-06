import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

import '/model/user_note.dart';
import '/service/text_to_speech.dart';
import '/util/util.dart';
import 'load.dart';
import 'menudrawer.dart';

///Script file
class Script extends StatelessWidget {
  ///Log
  final UserNote userNote;

  final _tts = TextToSpeech();

  ///Script to read
  Script({Key key, @required this.userNote}) : super(key: key);

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
        children: [
          TextHighlight(
            text: userNote.note,
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
          //TODO our add new text code goes here
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
                  // TODO delete code goes here
                },
                iconSize: 30.0,
                icon: Icon(
                  Icons.delete,
                  color: Colors.indigo,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO edit
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
