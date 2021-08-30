import 'package:collection/collection.dart';

import 'workout.dart';

/// utility functions
class Utils {
  /// turn seconds into formatted string e.g. 65 sec -> 01:05
  static String formatSeconds(int seconds) =>
      '${(seconds / 60).floor().toString().padLeft(2, '0')}:${seconds.remainder(60).toString().padLeft(2, '0')}';

  static String removeSpecialChar(String text) =>
      text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  static List<Workout> sortWorkouts(List<Workout> workouts) {
    workouts.sort((w1, w2) => w1.position != -1 && w2.position != -1
        ? w1.position.compareTo(w2.position)
        : compareNatural(w1.title, w2.title));
    return workouts;
  }
}
