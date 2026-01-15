import 'package:audioplayers/audioplayers.dart';
import 'package:prefs/prefs.dart';

// ignore: avoid_classes_with_only_static_members
class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool useSound = false;

  static Future<void> loadSounds() async {
    useSound = Prefs.getString('sound') == 'beep';
    // Configure audio player for low-latency playback
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  static Future<void> playBeepLow() async {
    if (useSound) {
      await _player.play(AssetSource('beep_low.wav'));
    }
  }

  static Future<void> playBeepHigh() async {
    if (useSound) {
      await _player.play(AssetSource('beep_high.wav'));
    }
  }

  static Future<void> playBeepTick() async {
    if (Prefs.getBool('ticks')) {
      await _player.play(AssetSource('tick.wav'));
    }
  }

  static Future<void> playDouble() async {
    if (useSound) {
      await _player.play(AssetSource('beep_low.wav'));
      await Future.delayed(const Duration(milliseconds: 200));
      await _player.play(AssetSource('beep_low.wav'));
    }
  }

  static Future<void> playTriple() async {
    if (useSound) {
      await _player.play(AssetSource('beep_high.wav'));
      await Future.delayed(const Duration(milliseconds: 150));
      await _player.play(AssetSource('beep_high.wav'));
      await Future.delayed(const Duration(milliseconds: 150));
      await _player.play(AssetSource('beep_high.wav'));
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
