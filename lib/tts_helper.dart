import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:prefs/prefs.dart';

// ignore: avoid_classes_with_only_static_members
/// handles everything related to TTS
class TTSHelper {
  static FlutterTts flutterTts = FlutterTts();

  static bool available = true;

  /// enable/disable TTS output
  static bool useTTS = true;

  static Future<void> init() async {
    flutterTts = FlutterTts();

    useTTS = Prefs.getString('sound') == 'tts';

    var ttsLang = Prefs.getString('tts_lang', 'en-US');
    if (ttsLang.endsWith('*')) ttsLang = ttsLang.replaceAll('*', '');
    await Prefs.setString('tts_lang', ttsLang);

    try {
      await flutterTts
          .setLanguage(ttsLang)
          .timeout(Duration(seconds: 1))
          .then((_) async {
        await flutterTts.setSpeechRate(1.0);
        await flutterTts.setVolume(1.0);
        await flutterTts.setPitch(1.0);
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
