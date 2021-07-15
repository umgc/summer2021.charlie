import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:sound_recorder/sound_recorder.dart';

import '/util/constant.dart';

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
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool _localAudioFileExists = false;

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
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                !_localAudioFileExists
                    ? _buildRecordAndStopControl(context)
                    : _buildPlayAndDelete(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordAndStopControl(BuildContext context) {
    return AvatarGlow(
      animate: _currentStatus == RecordingStatus.Recording,
      glowColor: Theme.of(context).primaryColor,
      endRadius: 75.0,
      duration: const Duration(milliseconds: 2000),
      repeatPauseDuration: const Duration(milliseconds: 100),
      repeat: true,
      child: FloatingActionButton(
          onPressed:
              _currentStatus == RecordingStatus.Recording ? _stop : _start,
          child: _buildIcon()),
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
    return Icon(icon, color: Colors.indigo, size: 30);
  }

  Widget _buildPlayAndDelete(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(width: 20),
        TextButton(
          onPressed: _onPlayAudio,
          child: Text("Play", style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent.withOpacity(0.5)),
        ),
        TextButton(
          onPressed: _onDeleteAudio,
          child: Text("Delete", style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent.withOpacity(0.5)),
        ),
      ],
    );
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
    var audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
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
}
