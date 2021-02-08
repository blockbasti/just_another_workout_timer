// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(count) => "${count} repetitions";

  static m1(title) => "Would you like to delete the workout \"${title}\"?";

  static m2(timeLeft, timeTotal) => "${timeLeft} of ${timeTotal} left";

  static m3(formattedTime) => "Duration: ${formattedTime}";

  static m4(currentIndex, total) => "Exercise ${currentIndex} of ${total}";

  static m5(name) => "First: ${name}";

  static m6(name) => "Next: ${name}";

  static m7(currentIndex, total) => "Repetition ${currentIndex} of ${total}";

  static m8(number) => "Set ${number}";

  static m9(currentIndex, total) => "Set ${currentIndex} of ${total}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "AnnounceUpcomingExerciseDesc" : MessageLookupByLibrary.simpleMessage("When TTS is enabled, announce the upcoming exercise"),
    "addExercise" : MessageLookupByLibrary.simpleMessage("Add exercise"),
    "addRest" : MessageLookupByLibrary.simpleMessage("Add rest"),
    "addSet" : MessageLookupByLibrary.simpleMessage("Add Set"),
    "addWorkout" : MessageLookupByLibrary.simpleMessage("Add workout"),
    "announceUpcomingExercise" : MessageLookupByLibrary.simpleMessage("Announce upcoming exercise"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "countRepetitions" : m0,
    "currentSet" : MessageLookupByLibrary.simpleMessage("Current set"),
    "delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteConfirmation" : m1,
    "deleteExercise" : MessageLookupByLibrary.simpleMessage("Delete exercise"),
    "deleteSet" : MessageLookupByLibrary.simpleMessage("Delete set"),
    "deleteWorkout" : MessageLookupByLibrary.simpleMessage("Delete workout"),
    "durationLeft" : m2,
    "durationWithTime" : m3,
    "editWorkout" : MessageLookupByLibrary.simpleMessage("Edit workout"),
    "english" : MessageLookupByLibrary.simpleMessage("English"),
    "enterWorkoutName" : MessageLookupByLibrary.simpleMessage("Please enter a name for the workout!"),
    "exercise" : MessageLookupByLibrary.simpleMessage("Exercise"),
    "exerciseOf" : m4,
    "exitCheck" : MessageLookupByLibrary.simpleMessage("Are you sure you want to exit?"),
    "firstExercise" : m5,
    "general" : MessageLookupByLibrary.simpleMessage("General"),
    "german" : MessageLookupByLibrary.simpleMessage("German"),
    "keepScreenAwake" : MessageLookupByLibrary.simpleMessage("Keep screen awake"),
    "language" : MessageLookupByLibrary.simpleMessage("Language"),
    "licenses" : MessageLookupByLibrary.simpleMessage("Licenses"),
    "moveExerciseDown" : MessageLookupByLibrary.simpleMessage("Move exercise down"),
    "moveExerciseUp" : MessageLookupByLibrary.simpleMessage("Move exercise up"),
    "moveSetDown" : MessageLookupByLibrary.simpleMessage("Move set down"),
    "moveSetUp" : MessageLookupByLibrary.simpleMessage("Move set up"),
    "name" : MessageLookupByLibrary.simpleMessage("Name"),
    "nextExercise" : m6,
    "nextSet" : MessageLookupByLibrary.simpleMessage("Next set"),
    "no" : MessageLookupByLibrary.simpleMessage("No"),
    "noSound" : MessageLookupByLibrary.simpleMessage("No sound effects"),
    "noSoundDesc" : MessageLookupByLibrary.simpleMessage("Mute all sound output"),
    "ossLicenses" : MessageLookupByLibrary.simpleMessage("Open Source Licenses"),
    "overwriteExistingWorkout" : MessageLookupByLibrary.simpleMessage("Overwrite existing workout?"),
    "repOf" : m7,
    "repetitions" : MessageLookupByLibrary.simpleMessage("Repetitions:"),
    "rest" : MessageLookupByLibrary.simpleMessage("Rest"),
    "saveWorkout" : MessageLookupByLibrary.simpleMessage("Save workout"),
    "setIndex" : m8,
    "setOf" : m9,
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "soundEffects" : MessageLookupByLibrary.simpleMessage("Sound Effects"),
    "soundOutput" : MessageLookupByLibrary.simpleMessage("Sound output"),
    "startWorkout" : MessageLookupByLibrary.simpleMessage("Start workout"),
    "title" : MessageLookupByLibrary.simpleMessage("Just Another Workout Timer"),
    "tts" : MessageLookupByLibrary.simpleMessage("Text-to-Speech (TTS)"),
    "ttsLang" : MessageLookupByLibrary.simpleMessage("TTS Language"),
    "ttsLangDesc" : MessageLookupByLibrary.simpleMessage("Select a locally installed language\n(only when TTS is enabled)"),
    "useSound" : MessageLookupByLibrary.simpleMessage("Use sound effects"),
    "useSoundDesc" : MessageLookupByLibrary.simpleMessage("Use simple sounds to indicate starts and endings of exercises"),
    "useTTS" : MessageLookupByLibrary.simpleMessage("Use Text-to-Speech"),
    "useTTSDesc" : MessageLookupByLibrary.simpleMessage("Announce current and upcoming exercises"),
    "viewLicense" : MessageLookupByLibrary.simpleMessage("View License"),
    "viewOSSLicenses" : MessageLookupByLibrary.simpleMessage("View Open Source Licenses"),
    "workoutComplete" : MessageLookupByLibrary.simpleMessage("Workout complete"),
    "yes" : MessageLookupByLibrary.simpleMessage("Yes"),
    "yesExit" : MessageLookupByLibrary.simpleMessage("Yes, exit")
  };
}
