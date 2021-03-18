import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preferences/dropdown_preference.dart';
import 'package:preferences/preference_page.dart';
import 'package:preferences/preference_title.dart';
import 'package:preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'generated/l10n.dart';
import 'oss_license_page.dart';
import 'sound_helper.dart';
import 'tts_helper.dart';

/// change some settings of the app and display licenses
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _license = '';

  void _loadLicense() async {
    var lic = await rootBundle.loadString('LICENSE');
    setState(() {
      _license = lic;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadLicense();
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settings),
        ),
        body: PreferencePage([
          PreferenceTitle(S.of(context).general),
          DropdownPreference(
            S.of(context).language,
            'lang',
            defaultVal: 'en',
            values: ['en', 'de', 'it'],
            displayValues: [
              S.of(context).english,
              S.of(context).german,
              S.of(context).italian
            ],
            onChange: (value) {
              setState(() {
                S.load(Locale(value));
              });
            },
          ),
          SwitchPreference(
            S.of(context).keepScreenAwake,
            'wakelock',
          ),
          SwitchPreference(S.of(context).settingHalfway, 'halftime'),
          SwitchPreference(S.of(context).playTickEverySecond, 'ticks'),
          PreferenceTitle(S.of(context).soundOutput),
          RadioPreference(
            S.of(context).noSound,
            'none',
            'sound',
            desc: S.of(context).noSoundDesc,
            onSelect: () {
              TTSHelper.useTTS = false;
              SoundHelper.useSound = false;
            },
          ),
          RadioPreference(
            S.of(context).useTTS,
            'tts',
            'sound',
            desc: S.of(context).useTTSDesc,
            isDefault: true,
            disabled: !TTSHelper.available,
            onSelect: () {
              TTSHelper.useTTS = true;
              SoundHelper.useSound = false;
            },
          ),
          RadioPreference(
            S.of(context).useSound,
            'beep',
            'sound',
            desc: S.of(context).useSoundDesc,
            onSelect: () {
              TTSHelper.useTTS = false;
              SoundHelper.useSound = true;
            },
          ),
          PreferenceTitle(S.of(context).tts),
          DropdownPreference(
            S.of(context).ttsLang,
            'tts_lang',
            desc: S.of(context).ttsLangDesc,
            defaultVal: (TTSHelper.languages.isNotEmpty
                ? TTSHelper.languages.first
                : ''),
            values: TTSHelper.languages,
            disabled: !TTSHelper.available,
            onChange: (value) {
              TTSHelper.flutterTts.setLanguage(value);
            },
          ),
          SwitchPreference(
            S.of(context).announceUpcomingExercise,
            'tts_next_announce',
            desc: S.of(context).AnnounceUpcomingExerciseDesc,
            disabled: !TTSHelper.available,
          ),
          PreferenceTitle(S.of(context).licenses),
          PreferenceText(
            S.of(context).viewOnGithub,
            subtitle: Text(S.of(context).reportIssuesOrRequestAFeature),
            onTap: () {
              launch(
                  'https://github.com/blockbasti/just_another_workout_timer');
            },
          ),
          PreferenceText(
            S.of(context).viewLicense,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                S.of(context).title,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(_license),
                            )
                          ],
                        ),
                      ));
            },
          ),
          PreferenceText(
            S.of(context).viewOSSLicenses,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OssLicensesPage(),
                  ));
            },
          )
        ]));
  }
}
