import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'script.dart';
import 'textmap.dart';

///LoadForm
class LoadForm extends StatefulWidget {
  _LoadFormState createState() => _LoadFormState();
}

class _LoadFormState extends State<LoadForm> {
  TextMap logs = TextMap();
  String rawText = "";
  String outputText = "";
  Map _decryptedJson;
  Map curMenu;
  bool onDates = true;

  //Attempt to load file as this screen opens
  void initState() {
    super.initState();

    Timer.run(() async {
      var fileText = await logs.getDecryptedContent();
      setState(() {
        _decryptedJson = logs.readJson(fileText);
        curMenu = _decryptedJson;
      });
    });

    Timer.run(() async {
      var rawContent = await logs.readFile();
      setState(() {
        rawText = json.encode(rawContent);
        outputText = logs.toJson(_decryptedJson);
      });
    });
  }

  void _buttonPressed(String dateTime) {
    setState(() {
      if (onDates) {
        onDates = false;
        curMenu = _decryptedJson[dateTime];
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Script(log: curMenu[dateTime] as String),
            ));
      }
    });
  }

  void _backButton() {
    setState(() {
      onDates = true;

      curMenu = _decryptedJson;
    });
  }

  Widget build(BuildContext context) {
    //Generating list of Dates for initial buttons
    List<String> dateTimes = curMenu.keys.toList();
    var listSize = dateTimes.length;
    if (!onDates) {
      listSize++;
    }

    return Scaffold(
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: listSize,
          itemBuilder: (context, i) {
            if (!onDates && i == listSize - 1) {
              //back button for list of times
              return ElevatedButton(
                onPressed: () {
                  _backButton();
                },
                child: Text("Back"),
              );
            }
            //Normal button for date or time listing
            return ElevatedButton(
              onPressed: () {
                _buttonPressed(dateTimes[i]);
              },
              child: Text(dateTimes[i]),
            );
          }),
    );
  }
}
