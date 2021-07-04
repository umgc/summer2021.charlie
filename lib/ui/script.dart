import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

import '/service/text_to_speech.dart';
import '/util/util.dart';
import 'load.dart';
import 'menudrawer.dart';

///Script file
class Script extends StatelessWidget {
  ///Log
  final String log;

  final _tts = TextToSpeech();

  ///Script to read
  Script({Key key, @required this.log}) : super(key: key);

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
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                //update the bottom app bar view each time an item is clicked
                onPressed: () {
                  _tts.speak(log);
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.blue.shade900,
                ),
              ),
              IconButton(
                onPressed: () {
                  //updateTabSelection(1, "Outgoing");
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.call_made,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(
                width: 50.0,
              ),
              IconButton(
                onPressed: () {
                  // updateTabSelection(2, "Incoming");
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.call_received,
                  color: Colors.blue.shade900,
                ),
              ),
              IconButton(
                onPressed: () {
                  // updateTabSelection(3, "Settings");
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.settings,
                  color: Colors.blue.shade900,
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
