import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

import 'migrations.dart';
import 'utils.dart';
import 'workout.dart';

Future<String> get localPath async {
  final directory = await getExternalStorageDirectory();
  await Directory('${directory!.path}/workouts').create();

  return directory.path;
}

Future<File> _loadWorkoutFile(String title) async {
  final path = await localPath;
  return File('$path/workouts/${Utils.removeSpecialChar(title)}.json');
}

Future<void> exportWorkout(String title) async {
  var workout = await loadWorkout(title: title);
  var backup = Backup(workouts: [workout]);
  final params = SaveFileDialogParams(
      data: Uint8List.fromList(jsonEncode(backup.toJson()).codeUnits), fileName: '${Utils.removeSpecialChar(title)}.json');
  await FlutterFileDialog.saveFile(params: params);
}

Future<void> exportAllWorkouts() async {
  var backup = Backup(workouts: await getAllWorkouts());
  final params = SaveFileDialogParams(data: Uint8List.fromList(jsonEncode(backup.toJson()).codeUnits), fileName: 'Backup.json');
  await FlutterFileDialog.saveFile(params: params);
}

Future<int> importBackup() async {
  const params = OpenFileDialogParams(dialogType: OpenFileDialogType.document, fileExtensionsFilter: ['json'], allowEditing: false);
  final filePath = await FlutterFileDialog.pickFile(params: params);
  if (filePath != null && filePath.isNotEmpty) {
    String backup;
    var file = File(filePath);
    try {
      backup = await file.readAsString();
    } on FileSystemException {
      // It might happen that encoding of files gets corrupted somehow.
      // Therefore loading is tried again with 'allowMalformed' flag.
      var bytes = await file.readAsBytes();
      backup = utf8.decode(bytes, allowMalformed: true);
      // TODO: What to do here? Log error? Show warning?
    }
    var workouts = Backup.fromJson(jsonDecode(backup)).workouts;
    workouts.forEach((w) => writeWorkout(w, fixDuplicates: true));
    await Migrations.runMigrations();
    return Future.value(workouts.length);
  } else {
    return Future.value(0);
  }
}

Future<void> writeWorkout(Workout workout, {bool fixDuplicates = false}) async {
  if (fixDuplicates) {
    var counter = 2;
    var newTitle = workout.title;

    while (await workoutExists(newTitle)) {
      newTitle = '${workout.title}($counter)';
      counter++;
    }
    workout.title = newTitle;
  }

  final file = await _loadWorkoutFile(workout.title);

  file.writeAsString(jsonEncode(workout.toJson()), flush: true);
}

Future<bool> workoutExists(String title) async {
  final file = await _loadWorkoutFile(title);
  return file.exists();
}

Future<Workout> loadWorkout({String? title, File? workoutFile}) async {
  final file = workoutFile ?? await _loadWorkoutFile(title!);
  var contents = await file.readAsString();

  return Workout.fromJson(jsonDecode(contents));
}

Future<void> deleteWorkout(String title) async {
  try {
    final file = await _loadWorkoutFile(title);
    file.delete();
    // ignore: empty_catches
  } on Exception {}
}

Future<void> createBackup() async {
  final path = await localPath;

  var dir = Directory('$path/workouts');
  var dirbak = Directory('$path/backup');
  try {
    dirbak.deleteSync();
  } on Exception catch (_) {}
  dirbak.createSync();

  Utils.copyDirectory(dir, dirbak);
  var backup = Backup(workouts: await getAllWorkouts());
  var backupfile = File('${dirbak.path}/backup.json');
  backupfile.writeAsBytesSync(Uint8List.fromList(jsonEncode(backup.toJson()).codeUnits));
}

Future<List<Workout>> getAllWorkouts() async {
  final path = await localPath;

  var dir = Directory('$path/workouts');
  var titles = dir.listSync().map((e) => e.path.split("/").last.split(".").first).toList();
  var list = (await Future.wait(titles.map((t) async => await loadWorkout(title: t))));
  return Utils.sortWorkouts(list);
}
