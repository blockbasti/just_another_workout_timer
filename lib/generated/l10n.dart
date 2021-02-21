// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Just Another Workout Timer`
  String get title {
    return Intl.message(
      'Just Another Workout Timer',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit?`
  String get exitCheck {
    return Intl.message(
      'Are you sure you want to exit?',
      name: 'exitCheck',
      desc: '',
      args: [],
    );
  }

  /// `Yes, exit`
  String get yesExit {
    return Intl.message(
      'Yes, exit',
      name: 'yesExit',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Would you like to delete the workout "{title}"?`
  String deleteConfirmation(Object title) {
    return Intl.message(
      'Would you like to delete the workout "$title"?',
      name: 'deleteConfirmation',
      desc: '',
      args: [title],
    );
  }

  /// `Duration: {formattedTime}`
  String durationWithTime(Object formattedTime) {
    return Intl.message(
      'Duration: $formattedTime',
      name: 'durationWithTime',
      desc: '',
      args: [formattedTime],
    );
  }

  /// `Edit workout`
  String get editWorkout {
    return Intl.message(
      'Edit workout',
      name: 'editWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Start workout`
  String get startWorkout {
    return Intl.message(
      'Start workout',
      name: 'startWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Delete workout`
  String get deleteWorkout {
    return Intl.message(
      'Delete workout',
      name: 'deleteWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Add workout`
  String get addWorkout {
    return Intl.message(
      'Add workout',
      name: 'addWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get licenses {
    return Intl.message(
      'Licenses',
      name: 'licenses',
      desc: '',
      args: [],
    );
  }

  /// `View License`
  String get viewLicense {
    return Intl.message(
      'View License',
      name: 'viewLicense',
      desc: '',
      args: [],
    );
  }

  /// `View Open Source Licenses`
  String get viewOSSLicenses {
    return Intl.message(
      'View Open Source Licenses',
      name: 'viewOSSLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licenses`
  String get ossLicenses {
    return Intl.message(
      'Open Source Licenses',
      name: 'ossLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Sound Effects`
  String get soundEffects {
    return Intl.message(
      'Sound Effects',
      name: 'soundEffects',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `German`
  String get german {
    return Intl.message(
      'German',
      name: 'german',
      desc: '',
      args: [],
    );
  }

  /// `Keep screen awake`
  String get keepScreenAwake {
    return Intl.message(
      'Keep screen awake',
      name: 'keepScreenAwake',
      desc: '',
      args: [],
    );
  }

  /// `Sound output`
  String get soundOutput {
    return Intl.message(
      'Sound output',
      name: 'soundOutput',
      desc: '',
      args: [],
    );
  }

  /// `No sound effects`
  String get noSound {
    return Intl.message(
      'No sound effects',
      name: 'noSound',
      desc: '',
      args: [],
    );
  }

  /// `Mute all sound output`
  String get noSoundDesc {
    return Intl.message(
      'Mute all sound output',
      name: 'noSoundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Use Text-to-Speech`
  String get useTTS {
    return Intl.message(
      'Use Text-to-Speech',
      name: 'useTTS',
      desc: '',
      args: [],
    );
  }

  /// `Announce current and upcoming exercises`
  String get useTTSDesc {
    return Intl.message(
      'Announce current and upcoming exercises',
      name: 'useTTSDesc',
      desc: '',
      args: [],
    );
  }

  /// `Use sound effects`
  String get useSound {
    return Intl.message(
      'Use sound effects',
      name: 'useSound',
      desc: '',
      args: [],
    );
  }

  /// `Use simple sounds to indicate starts and endings of exercises`
  String get useSoundDesc {
    return Intl.message(
      'Use simple sounds to indicate starts and endings of exercises',
      name: 'useSoundDesc',
      desc: '',
      args: [],
    );
  }

  /// `Text-to-Speech (TTS)`
  String get tts {
    return Intl.message(
      'Text-to-Speech (TTS)',
      name: 'tts',
      desc: '',
      args: [],
    );
  }

  /// `TTS Language`
  String get ttsLang {
    return Intl.message(
      'TTS Language',
      name: 'ttsLang',
      desc: '',
      args: [],
    );
  }

  /// `Select a language\n(only when TTS is enabled)`
  String get ttsLangDesc {
    return Intl.message(
      'Select a language\n(only when TTS is enabled)',
      name: 'ttsLangDesc',
      desc: '',
      args: [],
    );
  }

  /// `Announce upcoming exercise`
  String get announceUpcomingExercise {
    return Intl.message(
      'Announce upcoming exercise',
      name: 'announceUpcomingExercise',
      desc: '',
      args: [],
    );
  }

  /// `When TTS is enabled, announce the upcoming exercise`
  String get AnnounceUpcomingExerciseDesc {
    return Intl.message(
      'When TTS is enabled, announce the upcoming exercise',
      name: 'AnnounceUpcomingExerciseDesc',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name for the workout!`
  String get enterWorkoutName {
    return Intl.message(
      'Please enter a name for the workout!',
      name: 'enterWorkoutName',
      desc: '',
      args: [],
    );
  }

  /// `Overwrite existing workout?`
  String get overwriteExistingWorkout {
    return Intl.message(
      'Overwrite existing workout?',
      name: 'overwriteExistingWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Exercise`
  String get exercise {
    return Intl.message(
      'Exercise',
      name: 'exercise',
      desc: '',
      args: [],
    );
  }

  /// `Rest`
  String get rest {
    return Intl.message(
      'Rest',
      name: 'rest',
      desc: '',
      args: [],
    );
  }

  /// `Delete set`
  String get deleteSet {
    return Intl.message(
      'Delete set',
      name: 'deleteSet',
      desc: '',
      args: [],
    );
  }

  /// `Repetitions:`
  String get repetitions {
    return Intl.message(
      'Repetitions:',
      name: 'repetitions',
      desc: '',
      args: [],
    );
  }

  /// `Add exercise`
  String get addExercise {
    return Intl.message(
      'Add exercise',
      name: 'addExercise',
      desc: '',
      args: [],
    );
  }

  /// `Add rest`
  String get addRest {
    return Intl.message(
      'Add rest',
      name: 'addRest',
      desc: '',
      args: [],
    );
  }

  /// `Move set up`
  String get moveSetUp {
    return Intl.message(
      'Move set up',
      name: 'moveSetUp',
      desc: '',
      args: [],
    );
  }

  /// `Move set down`
  String get moveSetDown {
    return Intl.message(
      'Move set down',
      name: 'moveSetDown',
      desc: '',
      args: [],
    );
  }

  /// `Delete exercise`
  String get deleteExercise {
    return Intl.message(
      'Delete exercise',
      name: 'deleteExercise',
      desc: '',
      args: [],
    );
  }

  /// `Move exercise up`
  String get moveExerciseUp {
    return Intl.message(
      'Move exercise up',
      name: 'moveExerciseUp',
      desc: '',
      args: [],
    );
  }

  /// `Move exercise down`
  String get moveExerciseDown {
    return Intl.message(
      'Move exercise down',
      name: 'moveExerciseDown',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Save workout`
  String get saveWorkout {
    return Intl.message(
      'Save workout',
      name: 'saveWorkout',
      desc: '',
      args: [],
    );
  }

  /// `Add Set`
  String get addSet {
    return Intl.message(
      'Add Set',
      name: 'addSet',
      desc: '',
      args: [],
    );
  }

  /// `Set {number}`
  String setIndex(Object number) {
    return Intl.message(
      'Set $number',
      name: 'setIndex',
      desc: '',
      args: [number],
    );
  }

  /// `First: {name}`
  String firstExercise(Object name) {
    return Intl.message(
      'First: $name',
      name: 'firstExercise',
      desc: '',
      args: [name],
    );
  }

  /// `Next: {name}`
  String nextExercise(Object name) {
    return Intl.message(
      'Next: $name',
      name: 'nextExercise',
      desc: '',
      args: [name],
    );
  }

  /// `Workout complete`
  String get workoutComplete {
    return Intl.message(
      'Workout complete',
      name: 'workoutComplete',
      desc: '',
      args: [],
    );
  }

  /// `Exercise {currentIndex} of {total}`
  String exerciseOf(Object currentIndex, Object total) {
    return Intl.message(
      'Exercise $currentIndex of $total',
      name: 'exerciseOf',
      desc: '',
      args: [currentIndex, total],
    );
  }

  /// `Set {currentIndex} of {total}`
  String setOf(Object currentIndex, Object total) {
    return Intl.message(
      'Set $currentIndex of $total',
      name: 'setOf',
      desc: '',
      args: [currentIndex, total],
    );
  }

  /// `Repetition {currentIndex} of {total}`
  String repOf(Object currentIndex, Object total) {
    return Intl.message(
      'Repetition $currentIndex of $total',
      name: 'repOf',
      desc: '',
      args: [currentIndex, total],
    );
  }

  /// `{timeLeft} of {timeTotal} left`
  String durationLeft(Object timeLeft, Object timeTotal) {
    return Intl.message(
      '$timeLeft of $timeTotal left',
      name: 'durationLeft',
      desc: '',
      args: [timeLeft, timeTotal],
    );
  }

  /// `Current set`
  String get currentSet {
    return Intl.message(
      'Current set',
      name: 'currentSet',
      desc: '',
      args: [],
    );
  }

  /// `Next set`
  String get nextSet {
    return Intl.message(
      'Next set',
      name: 'nextSet',
      desc: '',
      args: [],
    );
  }

  /// `{count} repetitions`
  String countRepetitions(Object count) {
    return Intl.message(
      '$count repetitions',
      name: 'countRepetitions',
      desc: '',
      args: [count],
    );
  }

  /// `View on GitHub`
  String get viewOnGithub {
    return Intl.message(
      'View on GitHub',
      name: 'viewOnGithub',
      desc: '',
      args: [],
    );
  }

  /// `Report issues or request a feature`
  String get reportIssuesOrRequestAFeature {
    return Intl.message(
      'Report issues or request a feature',
      name: 'reportIssuesOrRequestAFeature',
      desc: '',
      args: [],
    );
  }

  /// `Halfway done`
  String get halfwayDone {
    return Intl.message(
      'Halfway done',
      name: 'halfwayDone',
      desc: '',
      args: [],
    );
  }

  /// `Play sound or announcement halfway during exercise`
  String get settingHalfway {
    return Intl.message(
      'Play sound or announcement halfway during exercise',
      name: 'settingHalfway',
      desc: '',
      args: [],
    );
  }

  /// `Play tick every second`
  String get playTickEverySecond {
    return Intl.message(
      'Play tick every second',
      name: 'playTickEverySecond',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate`
  String get duplicate {
    return Intl.message(
      'Duplicate',
      name: 'duplicate',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}