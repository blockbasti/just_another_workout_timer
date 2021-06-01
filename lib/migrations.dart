import 'dart:io';

import 'storage_helper.dart';
import 'utils.dart';

class Migrations {
  static final Map<int?, Function> _migrations = {null: _migrateV0toV1};

  static Future<void> _migrateFilenames() async {
    final path = await localPath;

    var dir = Directory('$path/workouts');
    dir.listSync().forEach((f) {
      var name = f.path.split('/').last.replaceAll('.json', '');
      name = Utils.removeSpecialChar(name);
      f.renameSync('${dir.path}/$name.json');
    });
  }

  static Future<void> _migrateV0toV1() async {}

  static Future<void> runMigrations() async {
    await _migrateFilenames();
  }
}
