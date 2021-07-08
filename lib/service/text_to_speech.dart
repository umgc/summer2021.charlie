import 'package:flutter_tts/flutter_tts.dart';

///Text to speech service
class TextToSpeech {
  ///Speak method for text to speech
  Future speak(String text) async {
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    await tts.setPitch(1);
    await tts.speak(text);
  }
}
