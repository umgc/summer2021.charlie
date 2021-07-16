import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '/ui/audio_recorder.dart';
import '/util/constant.dart';
import 'service/scheduled_delete_text.dart';
import 'ui/audio_recognize.dart';

/// This task runs periodically
const simplePeriodic1HourTask = "Old Notes Deleted";

/// callback dispatcher
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var scheduledDeleteText = ScheduledDeleteText();
    scheduledDeleteText.deleteText(7);
    print("$simplePeriodic1HourTask was executed");

    ///Return true when the task executed successfully or not
    return Future.value(true);
  });
}

void main() {
  ///Initializing work manager
  WidgetsFlutterBinding.ensureInitialized();

  ///void initialize() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  Workmanager().registerPeriodicTask(
    "6",
    simplePeriodic1HourTask,
    initialDelay: Duration(seconds: 10),
    frequency: Duration(minutes: 15),
  );

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
