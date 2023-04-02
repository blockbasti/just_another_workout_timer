import 'dart:io';

import 'storage_helper.dart';
import 'utils.dart';
import '../utils/workout.dart';

class Migrations {
  static late List<Workout> _workouts;

  static Future<void> _migrateFilenames() async {
    final path = await localPath;

    var dir = Directory('$path/workouts');
    dir.listSync().forEach((f) {
      var name = f.path.split('/').last.replaceAll('.json', '');
      name = Utils.removeSpecialChar(name);
      f.renameSync('${dir.path}/$name.json');
    });
  }

  static Future<void> _migrate(Workout workout, int index) async {
    while (workout.version < Workout.fileVersion) {
      switch (workout.version) {
        case 1:
          _migrateV1toV2(workout, index);
          break;
      }
    }
  }

  static Future<void> _migrateV1toV2(Workout workout, int index) async {
    workout.version = 2;
    if (workout.position == -1) {
      workout.position = index;
    }
    writeWorkout(workout);
  }

  static Future<void> runMigrations() async {
    await createBackup();
    await _migrateFilenames();
    _workouts = await getAllWorkouts();

    for (var workout in _workouts.asMap().entries) {
      await _migrate(workout.value, workout.key);
    }
  }
}
