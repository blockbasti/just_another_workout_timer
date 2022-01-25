import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:prefs/prefs.dart';

import 'languages.dart';

class TTSVoice {
  String name;
  String locale;

  TTSVoice(this.name, this.locale);

  @override
  String toString() => '{name: $name, locale: $locale}';
}

/// handles everything related to TTS
class TTSHelper {
  static FlutterTts flutterTts = FlutterTts();

  /// TTS is available?
  static bool available = true;

  /// enable/disable TTS output
  static bool useTTS = true;

  static bool isTalking = false;

  /// list of all available voices for TTS
  static List<TTSVoice> voices = [];

  static Future<void> init() async {
    flutterTts = FlutterTts();

    // populate the list of available TTS voices
    List<dynamic> allVoices = await flutterTts.getVoices;
    voices = allVoices.map((element) {
      Map e = element;
      var voice = TTSVoice(e.entries.first.value, e.entries.last.value);
      return voice;
    }).toList(growable: true);
    voices
        .retainWhere((voice) => Languages.languageCodes.contains(voice.locale));

    useTTS = Prefs.getString('sound') == 'tts';

    var ttsLang = Prefs.getString('tts_lang', 'en-US');
    await Prefs.setString('tts_lang', ttsLang);

    var ttsVoice = Prefs.getString('tts_voice', "");
    if (ttsVoice == "") {
      ttsVoice = voices.firstWhere((voice) => voice.locale == ttsLang).name;
      await Prefs.setString('tts_voice', ttsVoice);
    }

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
        await flutterTts.setVoice({"name": ttsVoice, "locale": ttsLang});
      });
    } on TimeoutException {
      available = false;
      useTTS = false;
      await Prefs.setString('sound', 'beep');
      return;
    }
  }

  static void setLanguage(String languageCode) async {
    if (!available) return;
    Prefs.setString("tts_lang", languageCode);
    await flutterTts.setLanguage(languageCode);

    var ttsVoice =
        voices.firstWhere((voice) => voice.locale == languageCode).name;
    await Prefs.setString('tts_voice', ttsVoice);
    await flutterTts.setVoice({"name": ttsVoice, "locale": languageCode});
  }

  static void speak(String text) async {
    if (!useTTS) return;
    await flutterTts.speak(text);
  }
}
