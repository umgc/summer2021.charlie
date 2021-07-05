import 'package:flutter/material.dart';

import 'menudrawer.dart';
import 'script.dart';
import 'textmap.dart';

///Edit file
class Edit extends StatelessWidget {
  ///Log: Text of this note.
  final String log;

  ///Date: Date of this note.
  final String date;

  final TextMap _logs = TextMap();

  ///Time: Time of this note.
  final String time;
  final _textController = TextEditingController();

  void _saveButtonPressed(BuildContext context) async {
    await _logs.changeLog(date, time, _textController.text);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Script(log: _textController.text, time: time, date: date),
        ));
  }

  void _cancelButtonPressed(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Script(log: log, time: time, date: date),
        ));
  }

  ///Edit constructor
  Edit({Key key, @required this.log, @required this.date, @required this.time})
      : super(key: key);

  Widget build(BuildContext context) {
    _textController.text = log;

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
