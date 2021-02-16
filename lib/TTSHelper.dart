import 'package:flutter_tts/flutter_tts.dart';
import 'package:preferences/preference_service.dart';

/// handles everything related to TTS
class TTSHelper {
  static FlutterTts flutterTts;

  static List<String> languages;

  /// enable/disable TTS output
  static bool useTTS = true;

  static Future<void> init() async {
    flutterTts = FlutterTts();

    useTTS = PrefService.getString('sound') == 'tts' ?? true;
    await flutterTts.setLanguage(PrefService.getString('tts_lang') ?? 'en-US');
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    languages = List<String>.from(await flutterTts.getLanguages);
    languages.sort();
    languages.remove('de-DE');
    languages.remove('en-US');
    languages.insertAll(0, ['en-US', 'de-DE']);
    languages = await Future.wait(languages.map((e) async =>
        '$e${await flutterTts.isLanguageInstalled(e) ? '' : '*'}'));
  }

  static speak(String text) async {
    if (!useTTS) return;
    await flutterTts.speak(text);
  }
}
