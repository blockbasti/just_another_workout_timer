class Utils {
  static String formatSeconds(int seconds) {
    return '${(seconds / 60).floor().toString().padLeft(2, '0')}:${seconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
