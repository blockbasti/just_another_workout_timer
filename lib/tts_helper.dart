import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:preferences/preference_service.dart';

// ignore: avoid_classes_with_only_static_members
/// handles everything related to TTS
class TTSHelper {
  static FlutterTts flutterTts;

  static bool available = true;

  /// enable/disable TTS output
  static bool useTTS = true;

  static Future<void> init() async {
    flutterTts = FlutterTts();

    useTTS = PrefService.getString('sound') == 'tts' ?? true;

    var ttsLang = PrefService.getString('tts_lang') ?? 'en-US';
    if (ttsLang.endsWith('*')) ttsLang = ttsLang.replaceAll('*', '');
    PrefService.setString('tts_lang', ttsLang);

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
      PrefService.setString('sound', 'beep');
      return;
    }
  }

  static void speak(String text) async {
    if (!useTTS) return;
    await flutterTts.speak(text);
  }
}
