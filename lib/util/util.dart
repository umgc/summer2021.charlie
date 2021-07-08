import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

import '/model/user_note.dart';

///String extension
extension StringExtensions on String {
  ///isNotNullOrEmpty
  bool isNotNullOrEmpty() => !isNullOrEmpty();

  ///isNullOrEmpty
  bool isNullOrEmpty() => this == null || isEmpty;
}

///texts to highlight
final Map<String, HighlightedWord> highlights = {
  'flutter': HighlightedWord(
      onTap: () {
        print('Flutter');
      },
      textStyle:
          const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
  'okay': HighlightedWord(
      onTap: () {
        print('okay');
      },
      textStyle:
          const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
};

///Get formatted text map
Map<String, Map<String, UserNote>> getFormattedTextMap(Map textMap) {
  var formattedMap = <String, Map<String, UserNote>>{};
  textMap.forEach((dateKey, timeMap) {
    var timeNoteMap = <String, UserNote>{};
    timeMap.forEach((timeKey, note) {
      timeNoteMap[timeKey] = getUserNote(note);
    });
    formattedMap[dateKey] = timeNoteMap;
  });
  return formattedMap;
}

///Get formatted text map
UserNote getUserNote(dynamic value) {
  if (value is String) {
    return UserNote(note: value, isFavorite: false);
  }

  return value is Map ? UserNote.fromJson(value) : value;
}
