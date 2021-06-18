import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

//texts to highlight
final Map<String, HighlightedWord> _highlights = {
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

class RecognizedContent extends StatelessWidget {
  final String text;

  const RecognizedContent({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextHighlight(
        text: text,
        words: _highlights,
        textStyle: const TextStyle(
            fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.w400),
      ),
    );
  }
}
