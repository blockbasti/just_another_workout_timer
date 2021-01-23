import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_another_workout_timer/OssLicensesPage.dart';
import 'package:just_another_workout_timer/SoundHelper.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:preferences/dropdown_preference.dart';
import 'package:preferences/preference_page.dart';
import 'package:preferences/preference_title.dart';
import 'package:preferences/preferences.dart';

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
          title: Text('Settings'),
        ),
        body: PreferencePage([
          PreferenceTitle('General'),
          SwitchPreference(
            'Keep screen awake',
            'wakelock',
            defaultVal: true,
          ),
          PreferenceTitle('Text-to-Speech (TTS)'),
          RadioPreference(
            'Use Text-to-Speech',
            'tts',
            'sound',
            isDefault: true,
            onSelect: () {
              setState(() {
                TTSHelper.useTTS = true;
                SoundHelper.useSound = false;
              });
            },
          ),
          DropdownPreference(
            'TTS Language',
            'tts_lang',
            defaultVal: 'en-US',
            values: TTSHelper.languages,
            //disabled: (!PrefService.getBool('tts_enable') ?? false),
            onChange: (value) {
              TTSHelper.flutterTts.setLanguage(value);
            },
          ),
          PreferenceTitle('Sound output'),
          RadioPreference(
            'Use sound effects',
            'beep',
            'sound',
            onSelect: () {
              TTSHelper.useTTS = false;
              SoundHelper.useSound = true;
            },
          ),
          PreferenceTitle('Licenses'),
          PreferenceText(
            'View License',
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Just Another Workout Timer',
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
                    );
                  });
            },
          ),
          PreferenceText(
            'View Open Source Licenses',
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
