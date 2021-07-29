import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/util/constant.dart';
import '/util/settingsloader.dart';
import '/util/textmap.dart';
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
  TextMap logs = TextMap();
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
  }

  void _resetSettingsPressed() async {
    await settingsLoader.resetSettings();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MySettingsScreen()),
    );
  }

  void _clearButtonPressed() async {
    await logs.clear();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MySettingsScreen()),
    );
  }

  _reRecordUsersVoice() async {
    await Constant.deleteFile(await Constant.getAudioRecordingFilePath());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioRecorder()),
    );
  }

  void _trainingVideo() async {
    const url = 'https://www.youtube.com/watch?v=Z7juO6O-yCQ';

    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.format_color_text),
            title: Text('Text Size', style: settingsLoader.getStyle(textSize)),
          ),
          Card(
            child: Slider(
                value: _textSliderValue,
                min: 10.0,
                max: 30.0,
                divisions: 10,
                label: _textSliderValue.round().toString(),
                onChanged: (var value) {
                  setState(() {
                    _textSliderValue = value;
                    textSize = value;
                    _saveChangesPressed();
                  });
                }),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text("Days Until Auto-Delete:",
                style: settingsLoader.getStyle(textSize)),
          ),
          Card(
            child: Slider(
                value: _daysSliderValue,
                min: 1,
                max: 30,
                divisions: 29,
                label: _daysSliderValue.round().toString(),
                onChanged: (var value) {
                  setState(() {
                    _daysSliderValue = value;
                    _saveChangesPressed();
                  });
                }),
          ),
          Card(
            child: ListTile(
                leading: const Icon(Icons.featured_video_outlined),
                title: Text('Training Video',
                    style: settingsLoader.getStyle(textSize)),
                onTap: () {
                  _trainingVideo();
                }),
          ),
          Card(
            child: ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: Text('Re-record Voice Profile',
                    style: settingsLoader.getStyle(textSize)),
                onTap: () {
                  _reRecordUsersVoice();
                }),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.subdirectory_arrow_left),
              title: Text('Reset Settings',
                  style: settingsLoader.getStyle(textSize)),
              onTap: () {
                _resetSettingsPressed();
              },
            ),
          ),
          Card(
            child: ListTile(
                leading: const Icon(Icons.phonelink_erase),
                title: Text('Delete All Notes',
                    style: settingsLoader.getStyle(textSize)),
                onTap: () {
                  _clearButtonPressed();
                }),
          ),
        ],
      ),
    );
  }
}
