import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'constant.dart';

///Settings Loader
class SettingsLoader {
  /*
  Current Format for Settings File:
  0: Text Size as Double
  1: Days Until Auto-Delete as integer
  */

  ///Writes the passed List to a local file as a json string
  void writeFile(List toWrite) async {
    var file = await _getFile();
    var convertedList = json.encode(toWrite);
    file.writeAsString(convertedList);
  }

  ///Loads the settings file and returns a list from json string
  Future<List> readFile() async {
    var file = await _getFile();

    if (!await file.exists()) {
      await writeFile(Constant.getDefaultSettings());
    }

    var fileString = await file.readAsString();

    return json.decode(fileString);
  }

  ///Gets the file from the path
  Future<File> _getFile() async {
    final textFilePath = await Constant.getSettingsFilePath();
    return File('$textFilePath');
  }

  ///Returns a TextStyle based on the passed double text size
  TextStyle getStyle(double textSize) {
    return TextStyle(
      fontSize: textSize,
    );
  }

  ///Restores the settings file to defaults
  void resetSettings() async {
    await writeFile(Constant.getDefaultSettings());
  }
}
