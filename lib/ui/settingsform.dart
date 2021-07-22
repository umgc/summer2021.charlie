import 'dart:async';

import 'package:flutter/material.dart';

import '/util/constant.dart';
import '/util/settingsloader.dart';
import 'audio_recorder.dart';
import 'settings.dart';

///Settings Form
class SettingsForm extends StatefulWidget {
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  //Default values in case file loading fails
  var _textSliderValue = 14.0;
  var _daysSliderValue = 7.0;
  List settingsList = [14.0, 7];
  SettingsLoader settingsLoader = SettingsLoader();
  double textSize = 14.0;

  //Attempt to load settings file as this screen opens.
  //If there is no settings file, one will be created with default values.
  void initState() {
    super.initState();

    Timer.run(() async {
      settingsList = await settingsLoader.readFile();

      setState(() {
        _textSliderValue = settingsList[0].toDouble();
        _daysSliderValue = settingsList[1].toDouble();

        textSize = _textSliderValue;
      });
    });
  }

  void _saveChangesPressed() {
    settingsList = [_textSliderValue, _daysSliderValue.toInt()];
    settingsLoader.writeFile(settingsList);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  void _resetSettingsPressed() {
    settingsLoader.resetSettings();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  void _deleteAllTexts() async {
    await Constant.deleteFile(await Constant.getTextFilePath());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  _reRecordUsersVoice() async {
    await Constant.deleteFile(await Constant.getAudioRecordingFilePath());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioRecorder()),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Text Size:", style: settingsLoader.getStyle(textSize)),
              Slider(
                  value: _textSliderValue,
                  min: 10.0,
                  max: 30.0,
                  divisions: 10,
                  label: _textSliderValue.round().toString(),
                  onChanged: (var value) {
                    setState(() {
                      _textSliderValue = value;
                    });
                  }),
              Text("Days Until Auto-Delete:",
                  style: settingsLoader.getStyle(textSize)),
              Slider(
                  value: _daysSliderValue,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: _daysSliderValue.round().toString(),
                  onChanged: (var value) {
                    setState(() {
                      _daysSliderValue = value;
                    });
                  }),
              ElevatedButton(
                onPressed: () {},
                child: Text("Training Video",
                    style: settingsLoader.getStyle(textSize)),
              ),
              ElevatedButton(
                onPressed: () {
                  _resetSettingsPressed();
                },
                child: Text("Reset Settings",
                    style: settingsLoader.getStyle(textSize)),
              ),
              ElevatedButton(
                onPressed: () {
                  _saveChangesPressed();
                },
                child: Text("Save Changes",
                    style: settingsLoader.getStyle(textSize)),
              ),
              ElevatedButton(
                onPressed: () {
                  _deleteAllTexts();
                },
                child: Text("Delete All Texts",
                    style: settingsLoader.getStyle(textSize)),
              ),
              ElevatedButton(
                onPressed: () {
                  _reRecordUsersVoice();
                },
                child: Text("Re-record User's Voice",
                    style: settingsLoader.getStyle(textSize)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
