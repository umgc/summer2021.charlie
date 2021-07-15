import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';

import '/util/constant.dart';
import '/util/textmap.dart';
import 'menudrawer.dart';
import 'recognized_content.dart';

///AudioRecognize UI
class AudioRecognize extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AudioRecognizeState();
}

class _AudioRecognizeState extends State<AudioRecognize> {
  final RecorderStream _recorder = RecorderStream();
  TextMap logs = TextMap();

  bool recognizing = false;
  bool recognizeFinished = false;
  String _text = '';
  StreamSubscription<List<int>> _audioStreamSubscription;
  BehaviorSubject<List<int>> _audioStream;
  String outputText = '';

  @override
  void initState() {
    super.initState();

    _recorder.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          Icons.memory_outlined,
          size: 40,
        ),
        title: Text(
          'Mnemosyne',
          style: TextStyle(fontSize: 25),
        ),
      ),
      endDrawer: MenuDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: recognizing,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: recognizing ? stopRecording : streamingRecognize,
          child: Icon(recognizing ? Icons.stop : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: <Widget>[
            if (recognizeFinished)
              (RecognizedContent(
                text: _text,
              )),
          ],
        ),
      ),
    );
  }

  void streamingRecognize() async {
    //Initializing the stream
    _audioStream = BehaviorSubject<List<int>>();

    //Getting the recorded audio file content and appending to the audiostream
    var _fileStream = await _getAudioStream();
    _fileStream.listen((event) {
      _audioStream.add(event);
    });

    //Listening to the mic
    _audioStreamSubscription = _recorder.audioStream.listen((event) {
      _audioStream.add(event);
    });

    await _recorder.start();

    setState(() {
      recognizing = true;
    });

    final serviceAccount = ServiceAccount.fromString(getServiceAccountJson());
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream);

    var responseText = '';

    responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join('\n');

      if (data.results.first.isFinal) {
        responseText += '\n$currentText';
        setState(() {
          _text = responseText;
          recognizeFinished = true;
          _saveText();
        });
      } else {
        setState(() {
          _text = '$responseText\n$currentText';
          recognizeFinished = true;
        });
      }
    }, onDone: () {
      setState(() {
        recognizing = false;
      });
    });
  }

  Future<Stream<List<int>>> _getAudioStream() async {
    final directory = await getApplicationDocumentsDirectory();
    // final path = '${'${directory.path}/'}myaudio.wav';
    // final path = '${directory.path}/$name';
    final myAudioPath = await Constant.getAudioRecordingFilePath();
    return File(myAudioPath).openRead();
  }

  String getServiceAccountJson() {
    const base64String =
        'ewogICAgInR5cGUiOiAic2VydmljZV9hY2NvdW50IiwKICAgICJwcm9qZWN0X2lkIjogImdyb292eS1ncmFuaXRlLTMxNzAwMiIsCiAgICAicHJpdmF0ZV9rZXlfaWQiOiAiMGNjNmQ0ZGI0NWI3MTllZGUxNjQ2MzViNTc0YWRhMTQ1NDFjN2VkYyIsCiAgICAicHJpdmF0ZV9rZXkiOiAiLS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tXG5NSUlFdlFJQkFEQU5CZ2txaGtpRzl3MEJBUUVGQUFTQ0JLY3dnZ1NqQWdFQUFvSUJBUURlZVVIeWdENGVnZkNHXG4wZnc3cWF1Q0VPa3VoVFFnbXdvUTdwd2lpQXo2OTAxdUhYOFlxWFpQOEV2ZWhSTU9Kcjk2WHpGV3hySnAySnpSXG5YT2UvbGZOa0VyRGlaUG85WEZCbjIxSHo2TVZwOGV0OEZ1V1A1QUd2VFRjLytnVkN3T3R5THk0dFBQMjZuNENjXG5WSWluVXBiZmZtQnhaQ3Q3Ukp4TDRGQVB2ekYxWks1V0RiRXNjeTZoTWVGYXJUUSttR3lmUkNLaWFqdDVsdnBaXG4wbnBra28xVVFxcEkyMHFHaEd3YmFiNnNNNnFhdVE2UjEwYlI3MlNEZ0xWS045OUtFOWFsUVFPVit0TXJjVTVoXG5ZYmdPZ0IxY3pVR05LOXJ2UFZRci9rMXhzZG9WTVh1QVlkYUQ1K093empRcE9DVnVTN21FY2hieC8zeEZrcExWXG4yWGNnU1BON0FnTUJBQUVDZ2dFQUs0SkpiSFM2TVZzMlFCZTNIYS84RTg3YzI3VS9VWlVncmRrTWZoQmZnWUYyXG5DakFJbURra0kxUWFjbVZTS2JWWVEwVjByOFRpUmFNUVlEMnNNU0xSVytQdjVnYmJqYjZORnhLa2YzQXBrNk8xXG5heXBMTVEzbGFuUk9kdHVkeGNWWEJwakZqaUZjZWZBUnhnRWVUS0x4VUxvMWdGZVh6VjdJdG1vakhrRkZHZkQrXG5aNk1zWHljVGZzY21DaWVRaG1ZejdmcnprbGhVOVVWWDBsWlRtUkczQkxQQUQyOHoxYUgzd1FYZlhPdzdmSzdIXG5GOHdpQWk2anZkWGM3ZTBybEFobTRKdlk2SjNzVTJvaUxPZFNhcEJQZEpCcGNFbjIxTW9KQnl0OE9ySWxzTkQ3XG5POS8wSGdockxEYjY2KzNJbjVOalp3YXpxSDdyMHhYVXFpd2ZPelQyWVFLQmdRRDJEMTdoQ1RQS2dVYzE4d290XG5lS2NlM2NDRVZxKzlkdlErYVFNRlpLWk1GMHZ4dWVwRENrUzYyQ2kxNkN1RzJFK1ErdkdTU1V6dWp3WGhyeE5CXG5JdjNYTE4xYlJ4bFpwU0JoMmFnb1JNWSs0b2o4TTQ5djVMNGpqc2NoRmNET3VnS01aMVFlRG9nRU9DZ1M1TUZXXG5LRUJzelFUbWdJK2RIOEpDNTJCVFVDOGpxd0tCZ1FEbmRmZnZqS2llVDNEUXBqaTc2ZElFeWdaMEd4MXZURHRlXG5uR3RrSjNiUEh4RnVJaTVETlpZcmV3Y0dDSkdnL3Fxd1FDci9QNG5xTmdwbWpoa3UwUVZJTEdwckNrdVRMeEFVXG5DWFpzcUMwVFhxK2J1S2dleEdtZlNIVXo4Z2ppalJWb0tQTGdXSVdvbkluSTdUUzAxMjVKNUZoRGFmbXVwdWkrXG5xaGFhU2ZtZmNRS0JnRkZTcXl6OCtaMElOUnpqZ28yY3ZyODQweFBxQXBNLzZXRm5HNVNBdTJXU25ZcjZ3eTM5XG5DdElsOXU2SUdUcXI2MEFqY0F2RkppUUNLUk41NVljMXBXZWtjRlJtbno0OWtRSkdDWW1sa1UvZlZ4N2plNWlqXG5wU1BqWUhUUzE3SjdUN1JQd2tGYzFCOXczKzIrcFJkd25qcFhXRE5HY2pDZituaGFPRC9RMUlPWkFvR0JBTHVvXG5DMEl1V2k4djNSbHRDcVpmcGlTMzNvK1h4RCtPSUx4T09VdFVLNkUxWVI1WG5BWmxsY0RlMkF6dU9aTzdwWXVNXG5HdEFqSlorNy9LYTFJbm13Z1lYSWJPY255Nm9qQi9nV3krckFWdnRUVXpEL2YxNmlnN2ZlT1JmS2JhV3dHT0VBXG5BaG9kNncrUENxN2FrbGJrS3NqQjEwV2cwQXZueXQ5NmF5VGdRUUFoQW9HQWFLQUpFemMzV0pWVWJEV3pFQTIrXG5NK2orbUJPZHRYakg2SzB6RkFYUVpSTUVESmZIaGwxOVhITWVpS0RDdmp3elFwOUxaNWp6TUVDQVZ5dG9qZ21zXG52OTRiZFMwL041T2F4aWZ4cnZ0enZLMEhzUmJJOFY5d2NNMlppWnFCVW13UFI2cEdKcEdxLy9xd0IzWHgxclc1XG5vbWIrc2M4SWtsQmpkTkdIRy9tRTViWT1cbi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS1cbiIsCiAgICAiY2xpZW50X2VtYWlsIjogInVtZ2MtY2hhcmxpZS1zcGVlY2gtdG8tdGV4dEBncm9vdnktZ3Jhbml0ZS0zMTcwMDIuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICAgImNsaWVudF9pZCI6ICIxMTA5ODAxMzI2MDI1MTMxODc1OTkiLAogICAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAgICJ0b2tlbl91cmkiOiAiaHR0cHM6Ly9vYXV0aDIuZ29vZ2xlYXBpcy5jb20vdG9rZW4iLAogICAgImF1dGhfcHJvdmlkZXJfeDUwOV9jZXJ0X3VybCI6ICJodHRwczovL3d3dy5nb29nbGVhcGlzLmNvbS9vYXV0aDIvdjEvY2VydHMiLAogICAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvdW1nYy1jaGFybGllLXNwZWVjaC10by10ZXh0JTQwZ3Jvb3Z5LWdyYW5pdGUtMzE3MDAyLmlhbS5nc2VydmljZWFjY291bnQuY29tIgogIH0=';
    // String.fromEnvironment('GOOGLE_SERVICE_ACCOUNT_BASE64');
    var base64Converter = utf8.fuse(base64);
    return base64Converter.decode(base64String);
  }

  void _saveText() {
    setState(() {
      var curDateTime = DateTime.now().toString();
      var curDate = curDateTime.substring(0, 10);
      var curTime = curDateTime.substring(11);

      logs.addLog(curDate, curTime, _text);

      outputText = "$curDateTime: $_text";
    });
  }

  void stopRecording() async {
    await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
    setState(() {
      recognizing = false;
    });
  }

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');
}
