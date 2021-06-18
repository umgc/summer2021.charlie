import 'dart:async';
import 'dart:io';
import 'dart:convert';

//path_provider needs to be downloaded
//use $ flutter pub add path_provider
import 'package:path_provider/path_provider.dart';

class TextMap {
  var dates = new Map();
  final String fileName = "memory.txt";

  //Adds log to the map matrix based on the passed date/time
  void addLog(String date, String time, String log) {
    //check if current date exists in map
    if (dates.containsKey(date)) {
      //existing date
      var times = dates[date];
      times[time] = log;
      dates[date] = times;
    } else {
      //new date
      var times = new Map();
      times[time] = log;
      dates[date] = times;
    }

    //Write to file after adding log
    _writeFile();
  }

  //Writes map to fil as JSON String
  _writeFile() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/' + fileName);
    await file.writeAsString(toJson());
  }

  //Clears the map and the text file
  void clear() {
    dates = new Map();
    _writeFile();
  }

  //Reads the file
  //Must be called outside of textmap as init
  Future<String> readFile() async {
    String text = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/' + fileName);
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  //Generate map from passed JSON String
  void readJson(String input) {
    if (input != "") {
      dates = json.decode(input);

      print(dates.toString());
    }
  }

  //Converts the map to a JSON String.
  String toJson() {
    return json.encode(dates);
  }
}
