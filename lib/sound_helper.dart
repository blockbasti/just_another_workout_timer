import 'package:flutter/services.dart';
import 'package:preferences/preference_service.dart';
import 'package:soundpool/soundpool.dart';

// ignore: avoid_classes_with_only_static_members
class SoundHelper {
  static Soundpool _soundpool;
  static int _beepId;
  static bool useSound = false;

  static Future<void> loadSounds() async {
    _soundpool ??= Soundpool(streamType: StreamType.notification);
    _beepId = await _loadSound();
    useSound = PrefService.getString('sound') == 'beep' ?? true;
  }

  static Future<int> _loadSound() async {
    var asset = await rootBundle.load('assets/beep.wav');
    return await _soundpool.load(asset);
  }

  static void playBeepLow() {
    if (useSound) _soundpool.play(_beepId);
  }

  static void playBeepHigh() {
    if (useSound) _soundpool.play(_beepId, rate: 1.5);
  }

  static void playBeepTick() {
    if (PrefService.getBool('ticks')) _soundpool.play(_beepId, rate: 2);
  }

  static void playDouble() {
    if (useSound) {
      _soundpool.play(_beepId);
      Future.delayed(Duration(milliseconds: 200))
          .then((value) => _soundpool.play(_beepId));
    }
  }
}
