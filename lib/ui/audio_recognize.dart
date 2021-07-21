import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_speech/generated/google/cloud/speech/v1/cloud_speech.pb.dart'
    as _cs;
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
    //Get the user recorded text
    var _userRecordedAudioText = await _getRecordedTextFile();

    //Initializing the stream
    _audioStream = BehaviorSubject<List<int>>();

    //Getting the recorded audio file content and appending to the audiostream
    var _fileStream = await Constant().getAudioStream();
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

    final speechToText = Constant.getSpeechToTextService();
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream);

    var responseText = 'START ---->$_userRecordedAudioText<---- END';

    responseStream.listen((data) {
      var currentText = '';

      if (data.results.first.isFinal) {
        for (var alt in data.results.first.alternatives) {
          for (var word in alt.words) {
            print(word.speakerTag);
            if (word.speakerTag == 1) {
              currentText += currentText.isNotEmpty ? ' ' : '';
              currentText += word.word;
            }
          }
        }
        responseText += '\n$currentText';
        _saveText();
        setState(() {
          _text = responseText;
          recognizeFinished = true;
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

  Future<String> _getRecordedTextFile() async {
    var audioTextFile = File(await Constant.getAudioTextFilePath());
    return await audioTextFile.readAsString();
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

  RecognitionConfig _getConfig() {
    var diarizationConfig = _cs.SpeakerDiarizationConfig();
    diarizationConfig.enableSpeakerDiarization = true;
    diarizationConfig.maxSpeakerCount = 1;
    diarizationConfig.maxSpeakerCount = 5;

    return RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'en-US',
        diarizationConfig: diarizationConfig);
  }
}
