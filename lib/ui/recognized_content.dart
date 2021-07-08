import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

import '/util/util.dart';

///RecognizedContent
class RecognizedContent extends StatelessWidget {
  ///Text string
  final String text;

  ///Constructor
  const RecognizedContent({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextHighlight(
        text: text,
        words: highlights,
        textStyle: const TextStyle(
            fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.w400),
      ),
    );
  }
}
