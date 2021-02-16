// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static m0(count) => "${count} Wiederholungen";

  static m1(title) => "Möchtest du das Workout \"${title}\" wirklich löschen?";

  static m2(timeLeft, timeTotal) => "${timeLeft} von ${timeTotal} übrig";

  static m3(formattedTime) => "Dauer: ${formattedTime}";

  static m4(currentIndex, total) => "Übung ${currentIndex} von ${total}";

  static m5(name) => "Beginnen mit: ${name}";

  static m6(name) => "Nächste Übung: ${name}";

  static m7(currentIndex, total) => "Wiederholung ${currentIndex} von ${total}";

  static m8(number) => "Satz ${number}";

  static m9(currentIndex, total) => "Satz ${currentIndex} von ${total}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "AnnounceUpcomingExerciseDesc" : MessageLookupByLibrary.simpleMessage("Wenn TTS aktiviert ist, wird die nächste Übung angesagt"),
    "addExercise" : MessageLookupByLibrary.simpleMessage("Übung hinzufügen"),
    "addRest" : MessageLookupByLibrary.simpleMessage("Pause hinzufügen"),
    "addSet" : MessageLookupByLibrary.simpleMessage("Satz hinzufügen"),
    "addWorkout" : MessageLookupByLibrary.simpleMessage("Workout erstellen"),
    "announceUpcomingExercise" : MessageLookupByLibrary.simpleMessage("nächste Übung ansagen"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "countRepetitions" : m0,
    "currentSet" : MessageLookupByLibrary.simpleMessage("Aktueller Satz"),
    "delete" : MessageLookupByLibrary.simpleMessage("Löschen"),
    "deleteConfirmation" : m1,
    "deleteExercise" : MessageLookupByLibrary.simpleMessage("Übung löschen"),
    "deleteSet" : MessageLookupByLibrary.simpleMessage("Satz löschen"),
    "deleteWorkout" : MessageLookupByLibrary.simpleMessage("Workout löschen"),
    "durationLeft" : m2,
    "durationWithTime" : m3,
    "editWorkout" : MessageLookupByLibrary.simpleMessage("Workout bearbeiten"),
    "english" : MessageLookupByLibrary.simpleMessage("Englisch"),
    "enterWorkoutName" : MessageLookupByLibrary.simpleMessage("Bitte einen Namen für das Workout festlegen!"),
    "exercise" : MessageLookupByLibrary.simpleMessage("Übung"),
    "exerciseOf" : m4,
    "exitCheck" : MessageLookupByLibrary.simpleMessage("Möchtest du wirklich beenden?"),
    "firstExercise" : m5,
    "general" : MessageLookupByLibrary.simpleMessage("Allgemein"),
    "german" : MessageLookupByLibrary.simpleMessage("Deutsch"),
    "halfwayDone" : MessageLookupByLibrary.simpleMessage("Hälfte geschafft"),
    "keepScreenAwake" : MessageLookupByLibrary.simpleMessage("Bildschirm angeschaltet lassen"),
    "language" : MessageLookupByLibrary.simpleMessage("Sprache"),
    "licenses" : MessageLookupByLibrary.simpleMessage("Lizenzen"),
    "moveExerciseDown" : MessageLookupByLibrary.simpleMessage("Übung nach unten verschieben"),
    "moveExerciseUp" : MessageLookupByLibrary.simpleMessage("Übung nach oben verschieben"),
    "moveSetDown" : MessageLookupByLibrary.simpleMessage("Satz nach unten verschieben"),
    "moveSetUp" : MessageLookupByLibrary.simpleMessage("Satz nach oben verschieben"),
    "name" : MessageLookupByLibrary.simpleMessage("Name"),
    "nextExercise" : m6,
    "nextSet" : MessageLookupByLibrary.simpleMessage("Nächster Satz"),
    "no" : MessageLookupByLibrary.simpleMessage("Nein"),
    "noSound" : MessageLookupByLibrary.simpleMessage("kein Ton"),
    "noSoundDesc" : MessageLookupByLibrary.simpleMessage("Ton stummschalten"),
    "ossLicenses" : MessageLookupByLibrary.simpleMessage("Open Source Lizenzen"),
    "overwriteExistingWorkout" : MessageLookupByLibrary.simpleMessage("Existierendes Workout überschreiben?"),
    "playTickEverySecond" : MessageLookupByLibrary.simpleMessage("Jede Sekunde ein Ticken abspielen"),
    "repOf" : m7,
    "repetitions" : MessageLookupByLibrary.simpleMessage("Wiederholungen:"),
    "reportIssuesOrRequestAFeature" : MessageLookupByLibrary.simpleMessage("Fehler melden oder neue Funktionen vorschlagen"),
    "rest" : MessageLookupByLibrary.simpleMessage("Pause"),
    "saveWorkout" : MessageLookupByLibrary.simpleMessage("Workout speichern"),
    "setIndex" : m8,
    "setOf" : m9,
    "settingHalfway" : MessageLookupByLibrary.simpleMessage("Ansage oder Ton in der Hälfte der Übung abspielen"),
    "settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "soundOutput" : MessageLookupByLibrary.simpleMessage("Tonausgabe"),
    "startWorkout" : MessageLookupByLibrary.simpleMessage("Workout starten"),
    "title" : MessageLookupByLibrary.simpleMessage("Just Another Workout Timer"),
    "tts" : MessageLookupByLibrary.simpleMessage("Text-zu-Sprache (TTS)"),
    "ttsLang" : MessageLookupByLibrary.simpleMessage("TTS Sprache"),
    "ttsLangDesc" : MessageLookupByLibrary.simpleMessage("Wähle eine Sprache aus\n(nur bei aktiviertem TTS)"),
    "useSound" : MessageLookupByLibrary.simpleMessage("Töne nutzen"),
    "useSoundDesc" : MessageLookupByLibrary.simpleMessage("Übungsbeginn und -ende mit einfachen Tönen ankündigen"),
    "useTTS" : MessageLookupByLibrary.simpleMessage("Text-zu-Sprache nutzen"),
    "useTTSDesc" : MessageLookupByLibrary.simpleMessage("Aktuelle und kommende Übungen ansagen"),
    "viewLicense" : MessageLookupByLibrary.simpleMessage("Lizenz anzeigen"),
    "viewOSSLicenses" : MessageLookupByLibrary.simpleMessage("Open Source Lizenzen anzeigen"),
    "viewOnGithub" : MessageLookupByLibrary.simpleMessage("Auf GitHub ansehen"),
    "workoutComplete" : MessageLookupByLibrary.simpleMessage("Workout abgeschlossen"),
    "yes" : MessageLookupByLibrary.simpleMessage("Ja"),
    "yesExit" : MessageLookupByLibrary.simpleMessage("Ja")
  };
}
