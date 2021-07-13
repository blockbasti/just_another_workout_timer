import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pref/pref.dart';
import 'package:prefs/prefs.dart';

import 'generated/l10n.dart';
import 'home_page.dart';
import 'sound_helper.dart';
import 'storage_helper.dart';
import 'tts_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance!.resamplingEnabled = true;
  await Prefs.init();
  PrefServiceShared.init(defaults: {
    'wakelock': true,
    'halftime': true,
    'ticks': false,
    'tts_next_announce': true,
    'sound': 'tts',
    'expanded_setlist': false
  }).then((service) => Future.wait([
        TTSHelper.init(),
        SoundHelper.loadSounds(),
        migrateFilenames(),
      ]).then((_) => runApp(PrefService(child: JAWTApp(), service: service))));
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
          toggleableActiveColor: Colors.lightBlue[300],
        ),
        home: HomePage(),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeListResolutionCallback: (locales, supportedLocales) {
          if (PrefService.of(context).get('lang') != null) {
            final locale = Locale(PrefService.of(context).get('lang'));
            if (supportedLocales.contains(locale)) return locale;
          }

          for (var locale in locales!) {
            if (supportedLocales.contains(locale)) {
              PrefService.of(context).set('lang', locale.languageCode);
              return locale;
            }
          }
          PrefService.of(context).set('lang', 'en');
          return Locale('en');
        },
      );
}
