import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:just_another_workout_timer/SoundHelper.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:preferences/preference_service.dart';

import 'HomePage.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;
  PrefService.init(prefix: 'pref_').then((value) =>
      Future.wait([TTSHelper.init(), SoundHelper.loadSounds()])
          .then((value) => runApp(JAWTApp())));
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
        if (PrefService.getString('lang') != null) {
          final locale = Locale(PrefService.getString('lang'));
          if (supportedLocales.contains(locale)) return locale;
        }

        for (Locale locale in locales) {
          if (supportedLocales.contains(locale)) {
            PrefService.setString('lang', locale.languageCode);
            return locale;
          }
        }
        PrefService.setString('lang', 'en');
        return Locale('en');
      },
    );
  }
}
