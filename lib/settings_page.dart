import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pref/pref.dart';
import 'package:prefs/prefs.dart';
import 'package:url_launcher/url_launcher.dart';

import 'generated/l10n.dart';
import 'oss_license_page.dart';
import 'sound_helper.dart';
import 'storage_helper.dart';
import 'tts_helper.dart';

/// change some settings of the app and display licenses
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _license;

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
        body: PrefPage(children: [
          PrefTitle(
            title: Text(
              S.of(context).general,
              style: TextStyle(color: Colors.blue),
            ),
          ),
          PrefDropdown(
            title: Text(S.of(context).language),
            items: [
              DropdownMenuItem(
                child: Text('English'),
                value: 'en',
              ),
              DropdownMenuItem(child: Text('Deutsch'), value: 'de'),
              DropdownMenuItem(child: Text('Italiano'), value: 'it'),
              DropdownMenuItem(child: Text('Français'), value: 'fr'),
              DropdownMenuItem(child: Text('Русский'), value: 'ru'),
              DropdownMenuItem(child: Text('Türkçe'), value: 'tr'),
            ],
            onChange: (String value) {
              setState(() {
                S.load(Locale(value));
              });
            },
            pref: 'lang',
          ),
          PrefDropdown(
              title: Text(S.of(context).theme),
              pref: 'theme',
              onChange: (_) {
                Phoenix.rebirth(context);
              },
              items: [
                DropdownMenuItem(
                    child: Text(S.of(context).theme_dark), value: 'dark'),
                DropdownMenuItem(
                    child: Text(S.of(context).theme_light), value: 'light'),
                DropdownMenuItem(
                    child: Text(S.of(context).theme_system), value: 'system'),
              ]),
          PrefSwitch(
            title: Text(S.of(context).keepScreenAwake),
            pref: 'wakelock',
          ),
          PrefSwitch(
              title: Text(S.of(context).settingHalfway), pref: 'halftime'),
          PrefSwitch(
              title: Text(S.of(context).playTickEverySecond), pref: 'ticks'),
          PrefSwitch(
              title: Text(S.of(context).expanded_setlist),
              subtitle: Text(S.of(context).expanded_setlist_info),
              pref: 'expanded_setlist'),
          PrefTitle(
              title: Text(S.of(context).backup,
                  style: TextStyle(color: Colors.blue))),
          PrefLabel(
            title: Text(S.of(context).export),
            onTap: exportAllWorkouts,
          ),
          PrefLabel(
            title: Text(S.of(context).import),
            onTap: () => {
              importBackup().then((value) => Fluttertoast.showToast(
                  msg: S.of(context).importedCount(value),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER))
            },
          ),
          PrefTitle(
              title: Text(S.of(context).soundOutput,
                  style: TextStyle(color: Colors.blue))),
          PrefRadio(
            title: Text(S.of(context).noSound),
            value: 'none',
            pref: 'sound',
            subtitle: Text(S.of(context).noSoundDesc),
            onSelect: () {
              TTSHelper.useTTS = false;
              SoundHelper.useSound = false;
            },
          ),
          PrefRadio(
            title: Text(S.of(context).useTTS),
            value: 'tts',
            pref: 'sound',
            subtitle: Text(S.of(context).useTTSDesc),
            disabled: !TTSHelper.available,
            onSelect: () {
              TTSHelper.useTTS = true;
              SoundHelper.useSound = false;
            },
          ),
          PrefRadio(
            title: Text(S.of(context).useSound),
            value: 'beep',
            pref: 'sound',
            subtitle: Text(S.of(context).useSoundDesc),
            onSelect: () {
              TTSHelper.useTTS = false;
              SoundHelper.useSound = true;
            },
          ),
          PrefTitle(
            title:
                Text(S.of(context).tts, style: TextStyle(color: Colors.blue)),
          ),
          PrefDropdown(
            title: Text(S.of(context).ttsLang),
            pref: 'tts_lang',
            subtitle: Text(S.of(context).ttsLangDesc),
            items: [
              DropdownMenuItem(
                child: Text('English'),
                value: 'en-US',
              ),
              DropdownMenuItem(child: Text('Deutsch'), value: 'de-DE'),
              DropdownMenuItem(child: Text('Italiano'), value: 'it-IT'),
              DropdownMenuItem(child: Text('Français'), value: 'fr-FR'),
              DropdownMenuItem(child: Text('Русский'), value: 'ru-RU'),
              DropdownMenuItem(child: Text('Türkçe'), value: 'tr-TR'),
            ],
            disabled: !TTSHelper.available,
            onChange: (String value) {
              TTSHelper.flutterTts.setLanguage(value);
            },
          ),
          PrefDropdown(
            title: Text(S.of(context).ttsVoice),
            pref: 'tts_voice',
            subtitle: Text(S.of(context).ttsVoiceDesc),
            items: TTSHelper.voices
                .where((voice) =>
                    voice.locale == Prefs.getString('tts_lang', 'en-US'))
                .toList()
                .asMap()
                .entries
                .map((voice) => DropdownMenuItem(
                        child: Text('${S.of(context).voice} ${voice.key+1} (${voice.value.name})'),
                        value: voice.value.name))
                .toList(),
            disabled: !TTSHelper.available,
            onChange: (String value) {
              TTSHelper.flutterTts.setVoice({"name": value, "locale": Prefs.getString('tts_lang', 'en-US')});
            },
          ),
          PrefSwitch(
            title: Text(S.of(context).announceUpcomingExercise),
            pref: 'tts_next_announce',
            subtitle: Text(S.of(context).AnnounceUpcomingExerciseDesc),
            disabled: !TTSHelper.available,
          ),
          PrefTitle(
              title: Text(S.of(context).licenses,
                  style: TextStyle(color: Colors.blue))),
          PrefLabel(
            title: Text(S.of(context).viewOnGithub),
            subtitle: Text(S.of(context).reportIssuesOrRequestAFeature),
            onTap: () {
              launch(
                  'https://github.com/blockbasti/just_another_workout_timer');
            },
          ),
          PrefLabel(
            title: Text(S.of(context).viewLicense),
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
          PrefLabel(
            title: Text(S.of(context).viewOSSLicenses),
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
