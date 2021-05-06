import 'package:flutter/services.dart';
import 'package:preferences/preference_service.dart';
import 'package:soundpool/soundpool.dart';

// ignore: avoid_classes_with_only_static_members
class SoundHelper {
  static Soundpool _soundpool = Soundpool(streamType: StreamType.music);
  static int? _beepLowId;
  static int? _beepHighId;
  static int? _tickId;
  static bool useSound = false;

  static Future<void> loadSounds() async {
    await _loadSounds();
    useSound = PrefService.getString('sound') == 'beep';
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
    if (PrefService.getBool('ticks')) _soundpool.play(_tickId);
  }

  static void playDouble() {
    if (useSound) {
      _soundpool.play(_beepLowId);
      Future.delayed(Duration(milliseconds: 200))
          .then((value) => _soundpool.play(_beepLowId));
    }
  }
}
