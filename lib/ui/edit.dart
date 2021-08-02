import 'package:flutter/material.dart';

import '/model/user_note.dart';
import '/util/settingsloader.dart';
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
  final SettingsLoader _settingsLoader = SettingsLoader();

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
              textSize: textSize * 2),
        ));
  }

  void _cancelButtonPressed(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Script(
              userNote: userNote,
              time: time,
              date: date,
              textSize: textSize * 2),
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
        leading: BackButton(color: Colors.white),
        title: Text("Note"),
      ),
      endDrawer: MenuDrawer(),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: 400.0,
              child: TextField(
                style: _settingsLoader.getStyle(textSize),
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter text to save.",
                ),
                maxLines: 4,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveButtonPressed(context);
                      },
                      child: Text("Save",
                          style: _settingsLoader.getStyle(textSize)),
                    )),
                SizedBox(
                    width: 400,
                    child: ElevatedButton(
                        onPressed: () {
                          _cancelButtonPressed(context);
                        },
                        child: Text("Cancel",
                            style: _settingsLoader.getStyle(textSize)),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white70,
                            onPrimary: Colors.indigo,
                            side: BorderSide(
                                style: BorderStyle.solid,
                                color: Colors.indigo,
                                width: 1)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
