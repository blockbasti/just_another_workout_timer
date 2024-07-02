import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

import 'workout.dart';

/// utility functions
class Utils {
  /// turn seconds into formatted string e.g. 65 sec -> 01:05
  static String formatSeconds(int seconds) =>
      '${(seconds / 60).floor().toString().padLeft(2, '0')}:${seconds.remainder(60).toString().padLeft(2, '0')}';

  static String removeSpecialChar(String text) =>
      text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  static List<Workout> sortWorkouts(List<Workout> workouts) {
    workouts.sort(
      (w1, w2) => w1.position != -1 && w2.position != -1
          ? w1.position.compareTo(w2.position)
          : compareNatural(w1.title, w2.title),
    );
    return workouts;
  }

  // https://gist.github.com/tobischw/98dcd2563eec9a2a87bda8299055358a
  static void copyDirectory(Directory source, Directory destination) =>
      source.listSync(recursive: false).forEach((var entity) {
        if (entity is Directory) {
          var newDirectory = Directory(
            path.join(destination.absolute.path, path.basename(entity.path)),
          );
          newDirectory.createSync();

          copyDirectory(entity.absolute, newDirectory);
        } else if (entity is File) {
          entity.copySync(
            path.join(destination.path, path.basename(entity.path)),
          );
        }
      });
}
