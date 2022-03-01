import 'package:flutter/services.dart';
import 'package:prefs/prefs.dart';
import 'package:soundpool/soundpool.dart';

// ignore: avoid_classes_with_only_static_members
class SoundHelper {
  static final Soundpool _soundpool = Soundpool.fromOptions(
      options: SoundpoolOptions(
    streamType: StreamType.music,
  ));
  static late int _beepLowId;
  static late int _beepHighId;
  static late int _tickId;

  static bool useSound = false;

  static Future<void> loadSounds() async {
    await _loadSounds();
    useSound = Prefs.getString('sound') == 'beep';
  }

  static Future<void> _loadSounds() async {
    var beepLow = await rootBundle.load('assets/beep_low.wav');
    var beepHigh = await rootBundle.load('assets/beep_high.wav');
    var tick = await rootBundle.load('assets/tick.wav');
    _beepLowId = await _soundpool.load(beepLow);
    _beepHighId = await _soundpool.load(beepHigh);
    _tickId = await _soundpool.load(tick);
  }

  static void playBeepLow() {
    if (useSound) _soundpool.play(_beepLowId);
  }

  static void playBeepHigh() {
    if (useSound) _soundpool.play(_beepHighId);
  }

  static void playBeepTick() {
    if (Prefs.getBool('ticks')) _soundpool.play(_tickId);
  }

  static void playDouble() {
    if (useSound) {
      _soundpool.play(_beepLowId);
      Future.delayed(Duration(milliseconds: 200))
          .then((value) => _soundpool.play(_beepLowId));
    }
  }

  static void playTriple() {
    if (useSound) {
      _soundpool.play(_beepHighId);
      Future.delayed(Duration(milliseconds: 150))
          .then((value) => _soundpool.play(_beepHighId))
          .then((value) => Future.delayed(Duration(milliseconds: 150))
              .then((value) => _soundpool.play(_beepHighId)));
    }
  }
}
