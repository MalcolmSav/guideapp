import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static FlutterTts tts = FlutterTts();

  static initTTs() async {
    tts.setLanguage("en-US");
    tts.setPitch(1.0);
  }

  // Future speak(var result) async {
  //   tts.speak(result);
  //   if (result == 1) setState(() => ttsState = TtsState.playing);
  // }

  static speak(String text) async {
    tts.setStartHandler(() {
      print("TTS started");
    });

    tts.setCompletionHandler(() {
      print("TTS complete");
    });

    tts.setErrorHandler((message) {
      print(message);
    });

    await tts.awaitSpeakCompletion(true);

    tts.speak(text);
  }

  static pause() async {
    await tts.pause();
  }
}
