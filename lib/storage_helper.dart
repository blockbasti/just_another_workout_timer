import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'utils.dart';
import 'workout.dart';

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();

  await Directory('${directory!.path}/workouts').create();

  return directory.path;
}

Future<File> _loadWorkoutFile(String title) async {
  final path = await _localPath;
  return File('$path/workouts/${Utils.removeSpecialChar(title)}.json');
}

void writeWorkout(Workout workout) async {
  final file = await _loadWorkoutFile(workout.title);

  file.writeAsString(workout.toRawJson(), flush: true);
}

Future<bool> workoutExists(String title) async {
  final file = await _loadWorkoutFile(title);
  return await file.exists();
}

Future<Workout> loadWorkout(String title) async {
  final file = await _loadWorkoutFile(title);
  var contents = await file.readAsString();

  return Workout.fromRawJson(contents);
}

Future<void> deleteWorkout(String title) async {
  try {
    final file = await _loadWorkoutFile(title);
    file.delete();
  } on Exception {}
}

Future<void> migrateFilenames() async {
  final path = await _localPath;

  var dir = Directory('$path/workouts');
  dir.listSync().forEach((f) {
    var name = f.path.split('/').last.replaceAll('.json', '');
    name = Utils.removeSpecialChar(name);
    f.renameSync('${dir.path}/$name.json');
  });
}

Future<List<Workout>> getAllWorkouts() async {
  final path = await _localPath;

  var dir = Directory('$path/workouts');
  var titles = dir
      .listSync()
      .map((e) => e.path.split("/").last.split(".").first)
      .toList();
  return await Future.wait(titles.map((t) async => await loadWorkout(t)));
}
