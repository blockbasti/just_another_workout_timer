import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:preferences/preference_service.dart';
import 'package:wakelock/wakelock.dart';

import 'HomePage.dart';

void main() async {
  runApp(JAWTApp());
  await PrefService.init(prefix: 'pref_');
  TTSHelper.init();
  Wakelock.enable();
}

class JAWTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Another Workout Timer',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue[800],
          accentColor: Colors.lightBlue[300],
          fontFamily: 'Roboto'),
      home: HomePage(),
    );
  }
}
