import 'dart:async';

import 'package:flutter/material.dart';

import '/model/user_note.dart';
import '/util/settingsloader.dart';
import '/util/textmap.dart';
import 'script.dart';

///Save form
class SaveForm extends StatefulWidget {
  _SaveFormState createState() => _SaveFormState();
}

class _SaveFormState extends State<SaveForm> {
  final textController = TextEditingController();
  String outputText = '';
  TextMap logs = TextMap();
  SettingsLoader settingsLoader = SettingsLoader();
  double textSize = 14.0;
  bool isLoading = true;

  void initState() {
    super.initState();

    //Load settings file
    Timer.run(() async {
      var settingsList = await settingsLoader.readFile();

      setState(() {
        textSize = settingsList[0];
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _buttonPressed() {
    setState(() {
      var inputText = textController.text;
      textController.text = "";

      var curDateTime = DateTime.now().toString();
      var curDate = curDateTime.substring(0, 10);
      var curTime = curDateTime.substring(11);

      logs.addLog(curDate, curTime, inputText);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Script(
                userNote: UserNote(note: inputText, isFavorite: false),
                time: curTime,
                date: curDate,
                textSize: (textSize * 2)),
          ));
    });
  }

  void _clearButtonPressed() {
    logs.clear();

    setState(() {
      outputText = "Save file cleared.";
    });
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          TextField(
            style: settingsLoader.getStyle(textSize),
            controller: textController,
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
                  _buttonPressed();
                },
                child: Text("Save", style: settingsLoader.getStyle(textSize)),
              ),
              ElevatedButton(
                onPressed: () {
                  _clearButtonPressed();
                },
                child: Text("Clear Save File",
                    style: settingsLoader.getStyle(textSize)),
              ),
            ],
          ),
          Text(outputText),
        ],
      ),
    );
  }
}
