import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

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
