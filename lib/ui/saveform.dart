import 'package:flutter/material.dart';
import 'dart:async';

import 'textmap.dart';

class SaveForm extends StatefulWidget {
  _SaveFormState createState() => _SaveFormState();
}

class _SaveFormState extends State<SaveForm> {
  final textController = TextEditingController();
  String outputText = '';
  TextMap logs = new TextMap();

  //Attempt to load file as this screen opens
  void initState() {
    super.initState();

    Timer.run(() async {
      String fileText = await logs.getDecryptedContent();
      setState(() {
        logs.readJson(fileText);
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
      String inputText = textController.text;
      textController.text = "";

      String curDateTime = DateTime.now().toString();
      String curDate = curDateTime.substring(0, 10);
      String curTime = curDateTime.substring(11);

      logs.addLog(curDate, curTime, inputText);

      outputText = curDateTime + ": " + inputText;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: textController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter text to save.",
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _buttonPressed();
            },
            child: Text("Save"),
          ),
          Text(outputText),
        ],
      ),
    );
  }
}
