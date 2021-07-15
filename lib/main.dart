import 'package:flutter/material.dart';

import '/ui/audio_recognize.dart';
import '/ui/audio_recorder.dart';
import '/util/constant.dart';

void main() {
  runApp(MyApp());
}

///MyApp a stateless widget
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mnemosyne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _getHome(context),
    );
  }

  Widget _getHome(context) {
    return FutureBuilder<Widget>(
        future: _getHomeWidget(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Future<Widget> _getHomeWidget() async {
    if (await _audioFileExists) {
      return AudioRecognize();
    }
    return AudioRecorder();
  }

  Future<bool> get _audioFileExists async {
    final audioFilePath = await Constant.getAudioRecordingFilePath();
    return Constant.getIfFileExists(audioFilePath);
  }
}
