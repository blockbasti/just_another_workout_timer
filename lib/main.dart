import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pref/pref.dart';
import 'package:prefs/prefs.dart';

import 'generated/l10n.dart';
import 'home_page.dart';
import 'migrations.dart';
import 'sound_helper.dart';
import 'tts_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance!.resamplingEnabled = true;
  await Prefs.init();

  PrefServiceShared.init(defaults: {
    'theme': 'system',
    'wakelock': true,
    'halftime': true,
    'ticks': false,
    'tts_next_announce': true,
    'sound': 'tts',
    'expanded_setlist': false
  }).then((service) => Future.wait([
        TTSHelper.init(),
        SoundHelper.loadSounds(),
        Migrations.runMigrations()
      ]).then((_) => runApp(
          PrefService(child: Phoenix(child: JAWTApp()), service: service))));
}

class JAWTApp extends StatelessWidget {
  ThemeMode? _brightness;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    switch (PrefService.of(context).get('theme')) {
      case 'system':
        _brightness = ThemeMode.system;
        break;
      case 'light':
        _brightness = ThemeMode.light;
        break;
      case 'dark':
        _brightness = ThemeMode.dark;
        break;
    }

    return MaterialApp(
      title: 'Just Another Workout Timer',
      themeMode: _brightness,
      theme: ThemeData(
          brightness: Brightness.light,
          toggleableActiveColor: Colors.blue,
          backgroundColor: Colors.white54,
          colorScheme: ColorScheme.highContrastLight().copyWith(
              secondary: Colors.blue,
              secondaryVariant: Colors.blue,
              primary: Colors.blue,
              primaryVariant: Colors.blueAccent)),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          toggleableActiveColor: Colors.blue,
          colorScheme: ColorScheme.highContrastDark().copyWith(
              secondary: Colors.blue,
              secondaryVariant: Colors.blue,
              primary: Colors.blue,
              primaryVariant: Colors.blueAccent)),
      home: HomePage(),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        if (PrefService.of(context).get('lang') != null) {
          final locale = Locale(PrefService.of(context).get('lang'));
          if (supportedLocales.contains(locale)) return locale;
        }

        for (var locale in locales!) {
          if (supportedLocales
              .any((element) => element.languageCode == locale.languageCode)) {
            PrefService.of(context).set('lang', locale.languageCode);
            return locale;
          }
        }
        PrefService.of(context).set('lang', 'en');
        return Locale('en');
      },
    );
  }
}
