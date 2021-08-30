import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:prefs/prefs.dart';

/// handles everything related to TTS
class TTSHelper {
  static FlutterTts flutterTts = FlutterTts();

  static bool available = true;

  /// enable/disable TTS output
  static bool useTTS = true;

  static bool isTalking = false;

  static Future<void> init() async {
    flutterTts = FlutterTts();

    useTTS = Prefs.getString('sound') == 'tts';

    var ttsLang = Prefs.getString('tts_lang', 'en-US');
    await Prefs.setString('tts_lang', ttsLang);

    flutterTts.setStartHandler(() {
      isTalking = true;
    });
    flutterTts.setCompletionHandler(() {
      isTalking = false;
    });

    try {
      await flutterTts
          .setLanguage(ttsLang)
          .timeout(Duration(seconds: 1))
          .then((_) async {
        await flutterTts.setVolume(1.0);
      });
    } on TimeoutException {
      available = false;
      useTTS = false;
      await Prefs.setString('sound', 'beep');
      return;
    }
  }

  static void speak(String text) async {
    if (!useTTS) return;
    await flutterTts.speak(text);
  }
}
