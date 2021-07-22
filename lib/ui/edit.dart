import 'package:flutter/material.dart';

import '/model/user_note.dart';
import '/util/textmap.dart';
import 'menudrawer.dart';
import 'script.dart';

///Edit file
class Edit extends StatelessWidget {
  ///Log: Text of this note.
  final UserNote userNote;

  ///Date: Date of this note.
  final String date;

  final TextMap _logs = TextMap();

  ///Time: Time of this note.
  final String time;

  ///textSize: Size of the text
  final double textSize;

  final _textController = TextEditingController();

  void _saveButtonPressed(BuildContext context) async {
    var editedUserNote =
        UserNote(note: _textController.text, isFavorite: userNote.isFavorite);
    await _logs.changeLog(date, time, editedUserNote);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Script(
              userNote: editedUserNote,
              time: time,
              date: date,
              textSize: textSize),
        ));
  }

  void _cancelButtonPressed(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Script(userNote: userNote, time: time, date: date),
        ));
  }

  ///Edit constructor
  Edit(
      {Key key,
      @required this.userNote,
      @required this.date,
      @required this.time,
      @required this.textSize})
      : super(key: key);

  Widget build(BuildContext context) {
    _textController.text = userNote.note;

    return Scaffold(
      appBar: AppBar(
        title: Text("Note"),
      ),
      endDrawer: MenuDrawer(),
      body: Column(
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter text to save.",
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _saveButtonPressed(context);
                },
                child: Text("Save"),
              ),
              ElevatedButton(
                onPressed: () {
                  _cancelButtonPressed(context);
                },
                child: Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
