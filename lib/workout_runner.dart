import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock/wakelock.dart';

import 'generated/l10n.dart';
import 'sound_helper.dart';
import 'tts_helper.dart';
import 'utils.dart';
import 'workout.dart';

/// page to do a workout
class WorkoutPage extends StatefulWidget {
  final Workout workout;

  const WorkoutPage({Key? key, required this.workout}) : super(key: key);

  @override
  WorkoutPageState createState() => WorkoutPageState(workout);
}

class WorkoutPageState extends State<WorkoutPage> {
  Timer? _timer;
  late Workout _workout;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  late Set _currentSet;
  late Exercise _currentExercise;
  int _currentReps = 0;

  Set? _nextSet;

  Exercise? _prevExercise;
  Exercise? _nextExercise;

  int _remainingSeconds = 10;
  int _currentSecond = 0;

  bool _workoutDone = false;

  /// timestamps of functions to announce current exercise (among other things)
  final Map<int, Function> _timetable = SplayTreeMap();

  @override
  void dispose() {
    _timer?.cancel();
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Prefs.getBool('wakelock', true)) Wakelock.enable();
    buildTimetable();
  }

  void skipForward() {
    if (_nextExercise != null || _currentSecond < 10) {
      setState(() {
        _currentSecond += _remainingSeconds - 1;
      });
      _timerStop();
      _timerStart();
      _timerTick();
    }
  }

  void skipBackward() {
    if (_prevExercise != null) {
      setState(() {
        _currentSecond -= (_currentExercise.duration - _remainingSeconds) + _prevExercise!.duration + 1;
      });
      _timerStop();
      _timerStart();
      _timerTick();
    }
  }

  void buildTimetable() {
    // init values
    setState(() {
      _currentSet = _workout.sets[0];
      _currentExercise = _workout.sets[0].exercises[0];
      _prevExercise = null;
      _nextExercise = null;
      _nextSet = _workout.sets.length > 1 ? _workout.sets[1] : null;
    });

    /// current timestamp
    var currentTime = 10;

    // announce first exercise
    _timetable[1] = () {
      TTSHelper.speak(S.of(context).firstExercise(_workout.sets[0].exercises[0].name));
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
          else if (exIndex + 1 == set.exercises.length && rep < set.repetitions - 1) {
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
          if ((Prefs.getString('sound') == 'tts' && Prefs.getBool('tts_next_announce')) && exercise.duration >= 10) {
            setMap[currentTime + exercise.duration - 9] = () {
              TTSHelper.speak(S.of(context).nextExercise(locNextExercise!.name));
            };
          } else if (_currentSecond > 10 && Prefs.getBool('ticks')) {
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
              } else if (!TTSHelper.isTalking && Prefs.getString('sound') == 'tts') {
                TTSHelper.speak(S.of(context).halfwayDone);
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
            setState(() {
              _itemScrollController.scrollTo(
                index: exIndex - 1 > 0 ? exIndex - 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
              _remainingSeconds = exercise.duration;
              if (_currentSet == set) {
                SoundHelper.playBeepHigh();
              } else {
                SoundHelper.playTriple();
              }
              _currentSet = set;
              _prevExercise = locPrevExercise;
              _nextExercise = locNextExercise;
              _currentExercise = exercise;
              _nextSet = locNextSet;
              _currentReps = rep;
              TTSHelper.speak(exercise.name);
            });
          };
          currentTime += exercise.duration;
        });
      }

      // announce completed workout
      _timetable[currentTime] = () {
        _timerStop();
        TTSHelper.speak(S.of(context).workoutComplete);
        setState(() {
          _workoutDone = true;
          _currentExercise = Exercise(name: S.of(context).workoutComplete, duration: 1);
        });
      };

      _timetable.addAll(setMap);
    });
  }

  void _timerStart() {
    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _timerTick();
      });
    });
  }

  void _timerTick() {
    setState(() {
      _currentSecond += 1;
      _remainingSeconds -= 1;

      if (_timetable.containsKey(_currentSecond)) {
        _timetable[_currentSecond]!();
      } else if (_currentSecond > 10 && Prefs.getBool('ticks')) {
        SoundHelper.playBeepTick();
      }
    });
  }

  void _timerStop() {
    setState(() {
      _timer?.cancel();
    });
  }

  void _resetWorkout() {
    setState(() {
      _workoutDone = false;
      _currentSet = Set(exercises: [], repetitions: 1);
      _currentExercise = Exercise(duration: 0, name: '');
      _currentReps = 1;

      _nextSet = Set(exercises: [], repetitions: 1);

      _remainingSeconds = 10;
      _currentSecond = 0;
    });

    _itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );

    buildTimetable();
  }

  Widget _buildCurrentSetList(Set? set) {
    if (set == null) return Container();

    var list = ScrollablePositionedList.builder(
      itemBuilder: (context, index) => _buildSetItem(set.exercises[index], set.exercises.indexOf(_currentExercise) == index),
      itemCount: set.exercises.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      shrinkWrap: true,
    );

    if (!Prefs.getBool('expanded_setlist', false)) {
      return SizedBox(
        height: 217,
        child: list,
      );
    } else {
      return list;
    }
  }

  Widget _buildNextSetList(Set? set) {
    if (set == null) return Container();

    return SizedBox(
      height: 217,
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index < set.exercises.length) {
            return _buildSetItem(set.exercises[index], set.exercises.indexOf(_currentExercise) == index);
          } else {
            return Container();
          }
        },
        itemCount: set.exercises.length,
        primary: false,
        shrinkWrap: true,
      ),
    );
  }

  Widget _buildSetItem(Exercise exercise, bool active) => ListTile(
        tileColor: active ? Theme.of(context).primaryColor : Theme.of(context).focusColor,
        title: Text(exercise.name),
        subtitle: Text(S.of(context).durationWithTime(Utils.formatSeconds(exercise.duration))),
      );

  WorkoutPageState(Workout workout) {
    _workout = workout;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_workout.title),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // left side of footer
            Expanded(
                child: ListTile(
              title: Text(S.of(context).exerciseOf(
                  _currentSet.exercises.indexOf(_currentExercise) + 1 + (_currentReps * _currentSet.exercises.length),
                  _currentSet.exercises.length * _currentSet.repetitions)),
              subtitle: Text(S.of(context).repOf(_currentReps + 1, _currentSet.repetitions)),
            )),
            // right side of footer
            Expanded(
                child: ListTile(
              title: Text(
                S.of(context).setOf(_workout.sets.indexOf(_currentSet) + 1, _workout.sets.length),
                textAlign: TextAlign.end,
              ),
              subtitle: Text(
                S.of(context).durationLeft(
                    Utils.formatSeconds(_workout.duration - _currentSecond + 10), Utils.formatSeconds(_workout.duration + 10)),
                textAlign: TextAlign.end,
              ),
            ))
          ],
        )),
        body: Column(
          children: [
            // top card with current exercise
            Card(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '${S.of(context).setIndex(_workout.sets.indexOf(_currentSet) + 1)} - ${Utils.formatSeconds(_remainingSeconds)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    LinearProgressIndicator(
                      value: _remainingSeconds / (_currentSecond < 10 ? 10 : _currentExercise.duration),
                      minHeight: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
                    ),
                    Text(
                      _currentExercise.name,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    _nextExercise != null
                        ? Text(
                            S.of(context).nextExercise(_nextExercise?.name ?? ''),
                            style: const TextStyle(fontSize: 24),
                            textAlign: TextAlign.center,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // card with current set
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(S.of(context).currentSet, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        _buildCurrentSetList(_currentSet),
                      ],
                    ),
                  ),
                  // card with next set
                  _nextSet != null
                      ? Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(S.of(context).nextSet, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                subtitle: _nextSet != null ? Text(S.of(context).countRepetitions(_nextSet!.repetitions)) : null,
                              ),
                              _buildNextSetList(_nextSet),
                            ],
                          ),
                        )
                      : Column()
                ],
              ),
            )
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'FAB1',
              mini: true,
              onPressed: skipBackward,
              child: const Icon(Icons.skip_previous),
            ),
            FloatingActionButton(
              heroTag: 'mainFAB',
              child: Icon(
                _timer != null && _timer!.isActive
                    ? Icons.pause
                    : _workoutDone
                        ? Icons.replay
                        : Icons.play_arrow,
                size: 32,
              ),
              onPressed: () {
                if (_timer != null && _timer!.isActive) {
                  _timerStop();
                } else if (_workoutDone) {
                  _resetWorkout();
                } else {
                  _timerStart();
                }
              },
            ),
            FloatingActionButton(
              heroTag: 'FAB2',
              mini: true,
              onPressed: skipForward,
              child: const Icon(Icons.skip_next),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
      onWillPop: () async {
        // Just pop if the workout wasn't started yet or is already done
        if (_timer == null || _workoutDone) {
          return true;
        }

        final value = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(S.of(context).exitCheck),
                  actions: <Widget>[
                    TextButton(
                      child: Text(S.of(context).no),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(S.of(context).yesExit),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ));

        return value == true;
      });
}
