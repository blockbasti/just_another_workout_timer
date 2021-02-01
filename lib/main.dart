import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_another_workout_timer/SoundHelper.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:preferences/preference_service.dart';

import 'HomePage.dart';
import 'generated/l10n.dart';

void main() async {
  runApp(JAWTApp());
}

class JAWTApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          PrefService.init(prefix: 'pref_'),
          TTSHelper.init(),
          SoundHelper.loadSounds()
        ]),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                if (snapshot.hasError) {
                  return Text('Error');
                } else {
                  return MaterialApp(
                    title: 'Just Another Workout Timer',
                    theme: ThemeData(
                        brightness: Brightness.dark,
                        primaryColor: Colors.blue[800],
                        accentColor: Colors.lightBlue[300],
                        fontFamily: 'Roboto',
                        cardTheme: CardTheme(elevation: 4),
                        unselectedWidgetColor: Colors.lightBlue[300],
                        toggleableActiveColor: Colors.lightBlue[300]),
                    home: HomePage(),
                    localizationsDelegates: [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    localeListResolutionCallback: (locales, supportedLocales) {
                      for (Locale locale in locales) {
                        if (supportedLocales.contains(locale)) {
                          return locale;
                        }
                      }
                      return Locale('de');
                    },
                  );
                }
              }
              break;
            case ConnectionState.none:
            case ConnectionState.waiting:
            default:
              return CircularProgressIndicator();
          }
        });
  }
}
