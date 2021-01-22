import 'package:flutter_tts/flutter_tts.dart';
import 'package:preferences/preference_service.dart';

/// handles everything related to TTS
class TTSHelper {
  static FlutterTts flutterTts;

  static List<String> languages;

  /// enable/disable TTS output
  static bool useTTS = true;

  static init() async {
    flutterTts = FlutterTts();

    useTTS = PrefService.getString('sound') == 'tts' ?? true;
    await flutterTts.setLanguage(PrefService.getString('tts_lang') ?? 'en-US');
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    List<dynamic> lang = await flutterTts.getLanguages;
    Map<dynamic, dynamic> langMap =
        await flutterTts.areLanguagesInstalled(lang.cast<String>());
    langMap.removeWhere((key, value) => !value);
    languages = langMap.keys.toList().cast<String>();
    languages.sort();
  }

  static speak(String text) async {
    if (!useTTS) return;
    await flutterTts.speak(text);
  }
}
