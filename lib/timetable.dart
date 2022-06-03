import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/sound_helper.dart';
import 'package:just_another_workout_timer/tts_helper.dart';
import 'package:just_another_workout_timer/workout.dart';
import 'package:prefs/prefs.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'generated/l10n.dart';

class Timetable with ChangeNotifier {
  final BuildContext _context;
  late final ItemScrollController itemScrollController;
  final Workout _workout;

  Timetable(this._context, this._workout);

  Timer? _timer;

  late Set currentSet;
  late Exercise currentExercise;
  int currentReps = 0;

  Set? nextSet;

  Exercise? prevExercise;
  Exercise? nextExercise;

  int remainingSeconds = 10;
  int currentSecond = 0;

  bool workoutDone = false;
  bool isInitialized = false;

  /// timestamps of functions to announce current exercise (among other things)
  final Map<int, Function> _timetable = SplayTreeMap();

  bool get canQuit => _timer == null || !_timer!.isActive || workoutDone;

  bool get isActive => _timer != null && _timer!.isActive;

  void skipForward() {
    if (nextExercise != null || currentSecond < 10) {
      currentSecond += remainingSeconds - 1;
      timerStop();
      timerStart();
      _timerTick();
      notifyListeners();
    }
  }

  void skipBackward() {
    if (prevExercise != null) {
      currentSecond -= (currentExercise.duration - remainingSeconds) +
          prevExercise!.duration +
          1;
      timerStop();
      timerStart();
      _timerTick();
      notifyListeners();
    }
  }

  void resetWorkout() {
    workoutDone = false;
    currentSet = Set(exercises: [], repetitions: 1);
    currentExercise = Exercise(duration: 0, name: '');
    currentReps = 1;

    nextSet = Set(exercises: [], repetitions: 1);

    remainingSeconds = 10;
    currentSecond = 0;

    itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );

    buildTimetable();
    notifyListeners();
  }

  void buildTimetable() {
    // init values
    currentSet = _workout.sets[0];
    currentExercise = _workout.sets[0].exercises[0];
    prevExercise = null;
    nextExercise = null;
    nextSet = _workout.sets.length > 1 ? _workout.sets[1] : null;

    /// current timestamp
    var currentTime = 10;

    // announce first exercise
    _timetable[1] = () {
      TTSHelper.speak(
          S.of(_context).firstExercise(_workout.sets[0].exercises[0].name));
    };

    // countdown to workout start
    _timetable[7] = () {
      TTSHelper.speak('3');
      SoundHelper.playBeepLow();
    };

    _timetable[8] = () {
      TTSHelper.speak('2');
      SoundHelper.playBeepLow();
    };

    _timetable[9] = () {
      TTSHelper.speak('1');
      SoundHelper.playBeepLow();
    };

    _workout.sets.asMap().forEach((setIndex, set) {
      var setMap = <int, Function>{};

      for (var rep = 0; rep < set.repetitions; rep++) {
        set.exercises.asMap().forEach((exIndex, exercise) {
          Set? locNextSet;
          Exercise? locNextExercise;
          Exercise? locPrevExercise;

          // case: exercise is somewhere in set
          if (exIndex + 1 < set.exercises.length) {
            locNextExercise = set.exercises[exIndex + 1];
            if (setIndex + 1 < _workout.sets.length) {
              locNextSet = _workout.sets[setIndex + 1];
            }
          }
          // case: exercise is last in set but set has remaining reps
          else if (exIndex + 1 == set.exercises.length &&
              rep < set.repetitions - 1) {
            locNextExercise = set.exercises.first;
          }
          // case: exercise is last in set and set is completed
          else if (setIndex + 1 < _workout.sets.length) {
            locNextExercise = _workout.sets[setIndex + 1].exercises.first;
          } else {
            locNextExercise = null;
          }

          // case: exercise is somewhere in set
          if (exIndex - 1 >= 0) {
            locPrevExercise = set.exercises[exIndex - 1];
          }
          // case: exercise is first in set and not in first rep
          else if (exIndex == 0 && rep > 0) {
            locPrevExercise = set.exercises.last;
          }
          // case: exercise is first in set and first rep
          else if (exIndex == 0 && rep == 0 && setIndex > 0) {
            locPrevExercise = _workout.sets[setIndex - 1].exercises.last;
          } else {
            locPrevExercise = null;
          }

          // announce next exercise
          if ((Prefs.getString('sound') == 'tts' &&
                  Prefs.getBool('tts_next_announce')) &&
              exercise.duration >= 10) {
            setMap[currentTime + exercise.duration - 9] = () {
              if (locNextExercise != null) {
                TTSHelper.speak(
                    S.of(_context).nextExercise(locNextExercise.name));
              }
            };
          } else if (currentSecond > 10 && Prefs.getBool('ticks')) {
            SoundHelper.playBeepTick();
          }

          // set next set
          if (setIndex + 1 < _workout.sets.length) {
            locNextSet = _workout.sets[setIndex + 1];
          }

          if (exercise.duration >= 10 && Prefs.getBool('halftime')) {
            setMap[(currentTime + exercise.duration / 2).round()] = () {
              if (Prefs.getString('sound') == 'beep') {
                SoundHelper.playDouble();
              } else if (!TTSHelper.isTalking &&
                  Prefs.getString('sound') == 'tts') {
                TTSHelper.speak(S.of(_context).halfwayDone);
              }
            };
          }

          // countdown to next exercise
          setMap[currentTime + exercise.duration - 3] = () {
            TTSHelper.speak('3');
            SoundHelper.playBeepLow();
          };

          setMap[currentTime + exercise.duration - 2] = () {
            TTSHelper.speak('2');
            SoundHelper.playBeepLow();
          };

          setMap[currentTime + exercise.duration - 1] = () {
            TTSHelper.speak('1');
            SoundHelper.playBeepLow();
          };

          // update display and announce current exercise
          setMap[currentTime] = () {
            itemScrollController.scrollTo(
              index: exIndex - 1 > 0 ? exIndex - 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
            remainingSeconds = exercise.duration;
            if (currentSet == set) {
              SoundHelper.playBeepHigh();
            } else {
              SoundHelper.playTriple();
            }
            currentSet = set;
            prevExercise = locPrevExercise;
            nextExercise = locNextExercise;
            currentExercise = exercise;
            nextSet = locNextSet;
            currentReps = rep;
            TTSHelper.speak(exercise.name);
          };
          currentTime += exercise.duration;
          notifyListeners();
        });
      }

      // announce completed workout
      _timetable[currentTime] = () {
        timerStop();
        TTSHelper.speak(S.of(_context).workoutComplete);

        workoutDone = true;
        currentExercise =
            Exercise(name: S.of(_context).workoutComplete, duration: 1);
        notifyListeners();
      };

      _timetable.addAll(setMap);
      isInitialized = true;
      //notifyListeners();
    });
  }

  void timerStart() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerTick();
    });
    notifyListeners();
  }

  void _timerTick() {
    currentSecond += 1;
    remainingSeconds -= 1;

    if (_timetable.containsKey(currentSecond)) {
      _timetable[currentSecond]!();
    } else if (currentSecond > 10 && Prefs.getBool('ticks')) {
      SoundHelper.playBeepTick();
    }
    notifyListeners();
  }

  void timerStop() {
    _timer?.cancel();
    notifyListeners();
  }
}
