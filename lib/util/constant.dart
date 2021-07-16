import 'dart:io';

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

  ///Get main text file path
  static Future<String> getTextFilePath() async {
    return await _getFilePath('memory.txt');
  }

  static Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${'${directory.path}/'}$fileName';
  }
}
