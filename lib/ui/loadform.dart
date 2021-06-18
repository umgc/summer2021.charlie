import 'package:flutter/material.dart';
import 'dart:async';

import 'textmap.dart';

class LoadForm extends StatefulWidget {
  _LoadFormState createState() => _LoadFormState();
}

class _LoadFormState extends State<LoadForm> {
  String outputText = "";
  TextMap logs = new TextMap();

  //Attempt to load file as this screen opens
  void initState() {
    super.initState();

    Timer.run(() async {
      String fileText = await logs.readFile();
      setState(() {
        logs.readJson(fileText);
      });
    });
  }

  void _loadButtonPressed() {
    setState(() {
      outputText = logs.toJson();
    });
  }

  void _deleteButtonPressed() {
    setState(() {
      logs.clear();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
        ],
      ),
    );
  }
}
