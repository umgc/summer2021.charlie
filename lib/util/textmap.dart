import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../model/user_note.dart';
import '../service/encryption_service.dart';
import 'constant.dart';
import 'util.dart';

///Text map for the JSON
class TextMap {
  final EncryptionService _encryptionService = EncryptionService();

  ///Adds log to the map matrix based on the passed date/time
  void addLog(String date, String time, String log) async {
    var fileText = await getDecryptedContent();
    var dateTimeText = readJson(fileText);
    var userNote = UserNote(note: log, isFavorite: false);
    //check if current date exists in map
    if (dateTimeText.containsKey(date)) {
      //existing date
      var times = dateTimeText[date];
      times[time] = userNote;
      dateTimeText[date] = times;
    } else {
      //new date
      var times = {};
      times[time] = userNote;
      dateTimeText[date] = times;
    }

    //Write to file after adding log
    writeFile(dateTimeText);
  }

  ///Changes the log at passed date/time to the passed log
  void changeLog(String date, String time, UserNote userNote) async {
    var fileText = await getDecryptedContent();
    var dateTimeText = readJson(fileText);
    var toChange = dateTimeText[date];

    toChange[time] = userNote;
    dateTimeText[date] = toChange;

    //Write to file after changing log
    await writeFile(dateTimeText);
  }

  ///Deletes the log at the passed date/time from the map matrix
  void deleteLog(String date, String time) async {
    var fileText = await getDecryptedContent();
    var dateTimeText = readJson(fileText);

    //Remove the time key first
    dateTimeText[date].remove(time);

    //If the date now has no times associated, it must also be removed
    if (dateTimeText[date].length == 0) {
      dateTimeText.remove(date);
    }

    //Write to file after deleting log
    await writeFile(dateTimeText);
  }

  ///Writes map to file as JSON String
  void writeFile(Map dateTimeText) async {
    var file = await getFile();
    var formattedMap = getFormattedTextMap(dateTimeText);
    var encryptedBase64 = _encryptionService.encrypt(toJson(formattedMap));
    file.writeAsString(encryptedBase64);
  }

  ///Clears the map and the text file
  void clear() {
    writeFile({});
  }

  ///Reads the file
  //Must be called outside of textmap as init
  Future<String> readFile() async {
    var file = await getFile();
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
  Future<File> getFile() async {
    final textFilePath = await Constant.getTextFilePath();
    return File('$textFilePath');
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
