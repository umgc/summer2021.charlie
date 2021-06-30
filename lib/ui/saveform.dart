import 'package:flutter/material.dart';

import 'textmap.dart';

///Save form
class SaveForm extends StatefulWidget {
  _SaveFormState createState() => _SaveFormState();
}

class _SaveFormState extends State<SaveForm> {
  final textController = TextEditingController();
  String outputText = '';
  TextMap logs = TextMap();

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

      outputText = "$curDateTime: $inputText";
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
