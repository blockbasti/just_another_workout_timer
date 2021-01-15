import 'dart:io';

import 'package:just_another_workout_timer/workout.dart';
import 'package:path_provider/path_provider.dart';

class StorageHelper {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    await Directory('${directory.path}/workouts').create();

    return directory.path;
  }

  static Future<File> _loadWorkoutFile(String title) async {
    final path = await _localPath;
    return File('$path/workouts/$title.json');
  }

  static writeWorkout(Workout workout) async {
    final file = await _loadWorkoutFile(workout.title);

    file.writeAsString(workout.toRawJson(), flush: true);
  }

  static Future<Workout> loadWorkout(String title) async {
    try {
      final file = await _loadWorkoutFile(title);

      String contents = await file.readAsString();

      return Workout.fromRawJson(contents);
    } catch (e) {
      return null;
    }
  }

  static deleteWorkout(String title) async {
    try {
      final file = await _loadWorkoutFile(title);
      file.delete();
    } catch (e) {
      return;
    }
  }

  static Future<List<Workout>> getAllWorkouts() async {
    final path = await _localPath;

    Directory dir = Directory('$path/workouts');
    var titles = dir
        .listSync()
        .map((e) => e.path.split("/").last.split(".").first)
        .toList();
    return await Future.wait(titles.map((t) async => await loadWorkout(t)));
  }
}
