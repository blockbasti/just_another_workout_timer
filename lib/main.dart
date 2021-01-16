import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:preferences/preference_service.dart';

import 'HomePage.dart';

void main() async {
  runApp(JAWTApp());
  await PrefService.init(prefix: 'pref_');
  TTSHelper.init();
}

class JAWTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Another Workout Timer',
      theme: ThemeData.dark(),
      home: HomePage(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('de', 'DE'),
      ],
    );
  }
}
