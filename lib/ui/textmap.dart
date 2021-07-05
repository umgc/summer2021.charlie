import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

//path_provider needs to be downloaded
//use $ flutter pub add path_provider
import '../service/encryption_service.dart';
import '../util/util.dart';

///Text map for the JSON
class TextMap {
  ///Use this file name for saving
  final String mainFileName = "memory.txt";
  final EncryptionService _encryptionService = EncryptionService();

  ///Adds log to the map matrix based on the passed date/time
  void addLog(String date, String time, String log) async {
    var fileText = await getDecryptedContent();
    var dateTimeText = readJson(fileText);
    //check if current date exists in map
    if (dateTimeText.containsKey(date)) {
      //existing date
      var times = dateTimeText[date];
      times[time] = log;
      dateTimeText[date] = times;
    } else {
      //new date
      var times = {};
      times[time] = log;
      dateTimeText[date] = times;
    }

    //Write to file after adding log
    writeFile(dateTimeText);
  }

  ///Writes map to fil as JSON String
  void writeFile(Map dateTimeText) async {
    var file = await getFile(mainFileName);
    var encryptedBase64 = _encryptionService.encrypt(toJson(dateTimeText));
    file.writeAsString(encryptedBase64);
  }

  ///Clears the map and the text file
  void clear() {
    writeFile({});
  }

  ///Reads the file
  //Must be called outside of textmap as init
  Future<String> readFile() async {
    var file = await getFile(mainFileName);
    if (!await file.exists()) {
      await writeFile({});
    }
    return await file.readAsString();
  }

  ///Gets decrypted content
  Future<String> getDecryptedContent() async {
    return _encryptionService.decrypt(await readFile());
  }

  ///Gets the file from the path
  Future<File> getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${'${directory.path}/'}$fileName');
  }

  ///Generate map from passed JSON String
  Map readJson(String input) {
    return input.isNotNullOrEmpty() ? json.decode(input) : {};
  }

  ///Converts the map to a JSON String.
  String toJson(Map dateTimeText) {
    return json.encode(dateTimeText);
  }
}
