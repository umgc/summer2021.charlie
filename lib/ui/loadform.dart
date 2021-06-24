import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'textmap.dart';

class LoadForm extends StatefulWidget {
  _LoadFormState createState() => _LoadFormState();
}

class _LoadFormState extends State<LoadForm> {
  TextMap logs = new TextMap();
  String rawText = "";
  String outputText = "";
  Map _decryptedJson;

  //Attempt to load file as this screen opens
  void initState() {
    super.initState();

    Timer.run(() async {
      String fileText = await logs.getDecryptedContent();
      setState(() {
        _decryptedJson = logs.readJson(fileText);
      });
    });

    Timer.run(() async {
      String rawContent = await logs.readFile();
      setState(() {
        rawText = json.encode(rawContent);
      });
    });
  }

  void _loadButtonPressed() {
    setState(() {
      outputText = logs.toJson(_decryptedJson);
    });
  }

  void _deleteButtonPressed() {
    setState(() {
      logs.clear();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _loadButtonPressed();
              },
              child: Text("Load JSON File"),
            ),
            Text(outputText),
            ElevatedButton(
              onPressed: () {
                _deleteButtonPressed();
              },
              child: Text("Clear JSON File"),
            ),
            Text(rawText),
          ],
        ),
      ),
    );
  }
}
