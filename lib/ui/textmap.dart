import 'dart:async';
import 'dart:io';
import 'dart:convert';

//path_provider needs to be downloaded
//use $ flutter pub add path_provider
import 'package:mnemosyne/service/encryption_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mnemosyne/util/util.dart';

class TextMap {
  final String mainFileName = "memory.txt";
  final EncryptionService _encryptionService = new EncryptionService();

  //Adds log to the map matrix based on the passed date/time
  void addLog(String date, String time, String log) async {
    String fileText = await readFile();
    Map dateTimeText = readJson(fileText);
    //check if current date exists in map
    if (dateTimeText.containsKey(date)) {
      //existing date
      var times = dateTimeText[date];
      times[time] = log;
      dateTimeText[date] = times;
    } else {
      //new date
      var times = new Map();
      times[time] = log;
      dateTimeText[date] = times;
    }

    //Write to file after adding log
    _writeFile(dateTimeText);
  }

  //Writes map to fil as JSON String
  _writeFile(Map dateTimeText) async {
    File file = await getFile(mainFileName);
    String encryptedBase64 = _encryptionService.encrypt(toJson(dateTimeText));
    file.writeAsString(encryptedBase64);
  }

  //Clears the map and the text file
  void clear() {
    _writeFile(new Map());
  }

  //Reads the file
  //Must be called outside of textmap as init
  Future<String> readFile() async {
    String encryptedStringBase64 = "";
    try {
      File file = await getFile(mainFileName);
      encryptedStringBase64 = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return encryptedStringBase64;
  }

  Future<String> getDecryptedContent() async {
    return _encryptionService.decrypt(await readFile());
  }

  Future<File> getFile(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/' + fileName);
  }

  //Generate map from passed JSON String
  Map readJson(String input) {
    return input.isNotNullOrEmpty() ? json.decode(input) : new Map();
  }

  //Converts the map to a JSON String.
  String toJson(Map dateTimeText) {
    return json.encode(dateTimeText);
  }
}
