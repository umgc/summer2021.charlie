import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:google_speech/google_speech.dart';
import 'package:sound_recorder/sound_recorder.dart';

import '/util/constant.dart';
import 'audio_recognize.dart';

///Audio recorder
class AudioRecorder extends StatefulWidget {
  /// Local file system
  final LocalFileSystem localFileSystem;

  ///Initialize
  AudioRecorder({localFileSystem})
      : localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  SoundRecorder _recorder;
  AudioPlayer _audioPlayer;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool _localAudioFileExists = false;
  String _audioText = '';
  Timer _timer;

  AudioPlayerState _playerState = AudioPlayerState.COMPLETED;

  Future<String> get _localAudioFilePath async {
    return await Constant.getAudioRecordingFilePath();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      if (await SoundRecorder.hasPermissions) {
        _localAudioFileExists = await Constant.getIfFileExists(
            await Constant.getAudioRecordingFilePath());
        _recorder = SoundRecorder(await _localAudioFilePath,
            audioFormat: AudioFormat.WAV);

        await _recorder.initialized;

        // after initialization
        var current = await _recorder.current(channel: 0);
        print('Current Recording Status: $current');
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You must accept permissions")));
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                !_localAudioFileExists
                    ? _buildRecordAndStopControl(context)
                    : _buildPlayAndDelete(context)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordAndStopControl(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Let\'s get you all set up...',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25),
          softWrap: true,
        ),
        SizedBox(height: 100),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          AvatarGlow(
            animate: _currentStatus == RecordingStatus.Recording,
            glowColor: Theme.of(context).primaryColor,
            endRadius: 75.0,
            duration: const Duration(milliseconds: 2000),
            repeatPauseDuration: const Duration(milliseconds: 100),
            repeat: true,
            child: FloatingActionButton(
                onPressed: _currentStatus == RecordingStatus.Recording
                    ? _stop
                    : _start,
                child: _buildIcon()),
          ),
          Text(
            'Press the mic button...\n\nSpeak for a couple of seconds...'
            '\n\nLet Mnemosyne recognize your voice...',
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 15),
            softWrap: true,
          )
        ])
      ],
    );
  }

  Widget _buildIcon() {
    var icon;
    switch (_currentStatus) {
      case RecordingStatus.Recording:
        {
          icon = Icons.stop;
          break;
        }
      case RecordingStatus.Initialized:
      case RecordingStatus.Stopped:
        {
          icon = Icons.mic;
          break;
        }
      default:
        break;
    }
    return Icon(icon, size: 30);
  }

  Widget _buildPlayAndDelete(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 70),
          Text(
            'How does it sound?',
            style: TextStyle(color: Colors.indigo, fontSize: 30),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                animate: _playerState == AudioPlayerState.PLAYING,
                glowColor: Theme.of(context).primaryColor,
                endRadius: 75.0,
                duration: const Duration(milliseconds: 1000),
                repeatPauseDuration: const Duration(milliseconds: 50),
                repeat: true,
                child: FloatingActionButton(
                    onPressed: _playerState == AudioPlayerState.PLAYING
                        ? _onStopAudioPlayer
                        : _onPlayAudio,
                    child: _buildPlayerIcon()),
              ),
            ],
          ),
          SizedBox(height: 75),
          Text(_audioText,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20)),
          SizedBox(height: 100),
          Row(children: <Widget>[
            Container(
              constraints: BoxConstraints(maxWidth: 150.0, minHeight: 40.0),
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _onDeleteAudio,
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 150.0, minHeight: 40.0),
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ]);
  }

  Widget _buildPlayerIcon() {
    var icon;
    switch (_playerState) {
      case AudioPlayerState.PLAYING:
        {
          icon = Icons.stop;
          break;
        }
      case AudioPlayerState.COMPLETED:
      case AudioPlayerState.STOPPED:
        {
          icon = Icons.play_arrow;
          break;
        }
      default:
        break;
    }
    return Icon(icon, size: 30);
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = Duration(milliseconds: 50);
      Timer.periodic(tick, (t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    var file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");

    await _transcribeAudioToText();
    var fileExists = await Constant.getIfFileExists(
        await Constant.getAudioRecordingFilePath());
    setState(() {
      _current = result;
      _currentStatus = _current.status;
      _localAudioFileExists = fileExists;
    });
  }

  ///On play audio
  _onPlayAudio() async {
    _audioText = '';
    _audioPlayer = AudioPlayer();
    await _audioPlayer.play(
        _current != null
            ? _current.path
            : await Constant.getAudioRecordingFilePath(),
        isLocal: true);
    await _transcribeAudioToText();
    const tick = Duration(milliseconds: 5);
    _timer = Timer.periodic(tick, (t) async {
      setState(() {
        _playerState = _audioPlayer.state;
      });
      if (_playerState == AudioPlayerState.COMPLETED) {
        t.cancel();
      }
    });
  }

  ///On play audio
  _onStopAudioPlayer() async {
    await _audioPlayer.stop();

    setState(() {
      _playerState = _audioPlayer.state;
      _timer.cancel();
    });
  }

  ///On continue
  void _onContinue() {
    if (_timer != null) {
      _timer.cancel();
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioRecognize()),
    );
  }

  ///On Delete audio
  _onDeleteAudio() async {
    try {
      var filePath = await _localAudioFilePath;
      var file = File('$filePath');
      await file.delete();
      print('<----- File deleted');
    } on Exception catch (e) {
      print(e);
    } finally {
      var fileExists = await Constant.getIfFileExists(
          await Constant.getAudioRecordingFilePath());
      if (!fileExists) {
        _currentStatus = RecordingStatus.Unset;
        _init();
      }
      setState(() {
        _localAudioFileExists = fileExists;
      });
    }
  }

  void _transcribeAudioToText() async {
    final speechToText = Constant.getSpeechToTextService();
    final config = _getConfig();

    final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        await Constant().getAudioStream());

    responseStream.listen((data) {
      setState(() {
        _audioText =
            data.results.map((e) => e.alternatives.first.transcript).join('\n');
      });
    }, onDone: () {
      setState(() {
        _saveAudioTextFile(_audioText);
      });
    });
  }

  void _saveAudioTextFile(String audioText) async {
    var file = File(await Constant.getAudioTextFilePath());
    file.writeAsString(audioText);
  }

  /*void _readFile() async {
    var file = File(await Constant.getAudioTextFilePath());
    if (!await file.exists()) {
      await _saveAudioTextFile('');
    }

    var audioText = await file.readAsString();
  }*/

  RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');
}
