import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_speech/google_speech.dart';
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
    final myAudioPath = await Constant.getAudioRecordingFilePath();
    return File(myAudioPath).openRead();
  }

  String getServiceAccountJson() {
    const base64String =
        String.fromEnvironment('GOOGLE_SERVICE_ACCOUNT_BASE64');
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
