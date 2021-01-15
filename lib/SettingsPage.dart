import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:preferences/dropdown_preference.dart';
import 'package:preferences/preference_page.dart';
import 'package:preferences/preference_title.dart';
import 'package:preferences/preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: PreferencePage([
          PreferenceTitle('Text-to-Speech (TTS)'),
          SwitchPreference(
            'Use Text-to-Speech',
            'tts_enable',
            defaultVal: true,
            onEnable: () {
              TTSHelper.useTTS = true;
            },
            onDisable: () {
              TTSHelper.useTTS = false;
            },
            onChange: () {
              setState(() {});
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
        ]));
  }
}
