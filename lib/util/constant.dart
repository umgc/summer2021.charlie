import 'dart:convert';
import 'dart:io';

import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';

///All constant values live here
class Constant {
  ///Check if file exists
  static Future<bool> getIfFileExists(String path) async {
    return File('$path').existsSync();
  }

  ///Get user's recorded file path
  static Future<String> getAudioRecordingFilePath() async {
    return await _getFilePath('my_audio.wav');
  }

  ///Get user's recorded file path
  static Future<String> getAudioTextFilePath() async {
    return await _getFilePath('my_audio_text.txt');
  }

  ///Get main text file path
  static Future<String> getTextFilePath() async {
    return await _getFilePath('memory.txt');
  }

  ///Get file path for settings file
  static Future<String> getSettingsFilePath() async {
    return await _getFilePath('memorySettings.txt');
  }

  ///Returns List of default settings
  static List getDefaultSettings() {
    //Current Defaults:
    //Text Size: 12.0
    //Days: 7
    return [14.0, 7];
  }

  static Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${'${directory.path}/'}$fileName';
  }

  ///Get speech to text service by the json file
  static SpeechToText getSpeechToTextService() {
    final serviceAccount = ServiceAccount.fromString(_getServiceAccountJson());
    return SpeechToText.viaServiceAccount(serviceAccount);
  }

  ///Get audio stream
  Future<Stream<List<int>>> getAudioStream() async {
    final myAudioPath = await getAudioRecordingFilePath();
    return File(myAudioPath).openRead();
  }

  static String _getServiceAccountJson() {
    const base64String =
        String.fromEnvironment('GOOGLE_SERVICE_ACCOUNT_BASE64');
    var base64Converter = utf8.fuse(base64);
    return base64Converter.decode(base64String);
  }
}
