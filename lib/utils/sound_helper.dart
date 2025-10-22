import 'package:prefs/prefs.dart';
import 'package:audioplayers/audioplayers.dart';

// ignore: avoid_classes_with_only_static_members
class SoundHelper {

  static final AssetSource _beepLowSource = AssetSource("beep_low.wav");
  static final AssetSource _beepHighSource = AssetSource("beep_high.wav");
  static final AssetSource _tickSource = AssetSource("tick.wav");
  static late AudioPlayer _player;

  static bool useSound = false;

  static Future<void> loadSounds() async {
    AudioLogger.logLevel = AudioLogLevel.info;
    await _loadSounds();
    useSound = Prefs.getString('sound') == 'beep';
  }

  static Future<void> _loadSounds() async {
    _player = AudioPlayer();
    await _player.setReleaseMode(ReleaseMode.stop);

    await _loadSound(_beepLowSource);
    await _loadSound(_beepHighSource);
    await _loadSound(_tickSource);
  }

  static Future<void> _loadSound(AssetSource src) async {
    await AudioCache.instance.load(src.path);
  }

  static void playBeepLow() {
    if (useSound) _player.play(_beepLowSource);
  }

  static void playBeepHigh() {
    if (useSound) _player.play(_beepHighSource);
  }

  static void playBeepTick() {
    if (Prefs.getBool('ticks')) _player.play(_tickSource);
  }

  static void playDouble() {
    if (useSound) {
      playBeepLow();
      Future.delayed(const Duration(milliseconds: 200))
          .then((value) => playBeepLow());
    }
  }

  static void playTriple() {
    if (useSound) {
      playBeepHigh();
      Future.delayed(const Duration(milliseconds: 150))
          .then((value) => playBeepHigh())
          .then(
            (value) => Future.delayed(const Duration(milliseconds: 150))
                .then((value) => playBeepHigh()),
          );
    }
  }

  // TODO does this need to be called somewhere?
  static void dispose() async {
    await _player.dispose();
  }
}
