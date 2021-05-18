import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_another_workout_timer/sound_helper.dart';
import 'package:just_another_workout_timer/storage_helper.dart';
import 'package:just_another_workout_timer/tts_helper.dart';
import 'package:just_another_workout_timer/workout.dart';
import 'package:just_another_workout_timer/workout_builder.dart';
import 'package:prefs/prefs.dart';

import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance!.resamplingEnabled = true;
  Prefs.init().then((_) => Future.wait(
          [TTSHelper.init(), SoundHelper.loadSounds(), migrateFilenames()])
      .then((_) => runApp(JAWTApp())));
}

class JAWTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Just Another Workout Timer',
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blue[800],
            accentColor: Colors.lightBlue[300],
            cardTheme: CardTheme(elevation: 4),
            unselectedWidgetColor: Colors.lightBlue[300],
            toggleableActiveColor: Colors.lightBlue[300]),
        home: BuilderPage(workout: Workout(), newWorkout: true), //HomePage(),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeListResolutionCallback: (locales, supportedLocales) {
          if (Prefs.getString('lang', '') != '') {
            final locale = Locale(Prefs.getString('lang'));
            if (supportedLocales.contains(locale)) return locale;
          }

          for (var locale in locales!) {
            if (supportedLocales.contains(locale)) {
              Prefs.setString('lang', locale.languageCode);
              return locale;
            }
          }
          Prefs.setString('lang', 'en');
          return Locale('en');
        },
      );
}
