/// utility functions
class Utils {
  /// turn seconds into formatted string e.g. 65 sec -> 01:05
  static String formatSeconds(int seconds) =>
      '${(seconds / 60).floor().toString().padLeft(2, '0')}:${seconds.remainder(60).toString().padLeft(2, '0')}';
}
