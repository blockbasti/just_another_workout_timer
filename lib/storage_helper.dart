import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
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

Future<void> exportWorkout(String title) async {
  var workout = await loadWorkout(title: title);
  var backup = Backup(workouts: [workout]);
  final params = SaveFileDialogParams(
      data: Uint8List.fromList(backup.toRawJson().codeUnits),
      fileName: '${Utils.removeSpecialChar(title)}.json');
  await FlutterFileDialog.saveFile(params: params);
}

Future<void> exportAllWorkouts() async {
  var backup = Backup(workouts: await getAllWorkouts());
  final params = SaveFileDialogParams(
      data: Uint8List.fromList(backup.toRawJson().codeUnits),
      fileName: 'Backup.json');
  await FlutterFileDialog.saveFile(params: params);
}

Future<int> importBackup() async {
  final params = OpenFileDialogParams(
      dialogType: OpenFileDialogType.document,
      fileExtensionsFilter: ['json'],
      allowEditing: false);
  final filePath = await FlutterFileDialog.pickFile(params: params);
  if (filePath != null && filePath.isNotEmpty) {
    var backup = await File(filePath).readAsString();
    var workouts = Backup.fromRawJson(backup).workouts;
    workouts.forEach((w) => writeWorkout(w, fixDuplicates: true));
    return Future.value(workouts.length);
  } else {
    return Future.value(0);
  }
}

Future<void> writeWorkout(Workout workout, {bool fixDuplicates = false}) async {
  if (fixDuplicates) {
    var counter = 2;
    var newTitle = '${workout.title}';

    while (await workoutExists(newTitle)) {
      newTitle = '${workout.title}($counter)';
    }
    workout.title = newTitle;
  }

  final file = await _loadWorkoutFile(workout.title);
  file.writeAsString(workout.toRawJson(), flush: true);
}

Future<bool> workoutExists(String title) async {
  final file = await _loadWorkoutFile(title);
  return file.exists();
}

Future<Workout> loadWorkout({String? title, File? workoutFile}) async {
  final file = workoutFile ?? await _loadWorkoutFile(title!);
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
  return await Future.wait(
      titles.map((t) async => await loadWorkout(title: t)));
}
