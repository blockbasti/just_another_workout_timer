import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';
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

  WorkoutPage({Key key, @required this.workout}) : super(key: key);

  @override
  _WorkoutPageState createState() => _WorkoutPageState(workout);
}

class _WorkoutPageState extends State<WorkoutPage> {
  Timer _timer;
  Workout _workout;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  Set _currentSet;
  Exercise _currentExercise;
  int _currentReps = 0;

  Set _nextSet;

  Exercise _prevExercise;
  Exercise _nextExercise;

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
    if (PrefService.getBool('wakelock') ?? true) Wakelock.enable();
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
        _currentSecond -= (_currentExercise.duration - _remainingSeconds) +
            _prevExercise.duration +
            1;
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
    var _currentTime = 10;

    // announce first exercise
    _timetable[1] = () {
      TTSHelper.speak(
          S.of(context).firstExercise(_workout.sets[0].exercises[0].name));
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
          Set _locNextSet;
          Exercise _locNextExercise;
          Exercise _locPrevExercise;

          // case: exercise is somewhere in set
          if (exIndex + 1 < set.exercises.length) {
            _locNextExercise = set.exercises[exIndex + 1];
            if (setIndex + 1 < _workout.sets.length) {
              _locNextSet = _workout.sets[setIndex + 1];
            }
          }
          // case: exercise is last in set but set has remaining reps
          else if (exIndex + 1 == set.exercises.length &&
              rep < set.repetitions - 1) {
            _locNextExercise = set.exercises.first;
          }
          // case: exercise is last in set and set is completed
          else if (setIndex + 1 < _workout.sets.length) {
            _locNextExercise = _workout.sets[setIndex + 1].exercises.first;
          } else {
            _locNextExercise = null;
          }

          // case: exercise is somewhere in set
          if (exIndex - 1 >= 0) {
            _locPrevExercise = set.exercises[exIndex - 1];
          }
          // case: exercise is first in set and not in first rep
          else if (exIndex == 0 && rep > 0) {
            _locPrevExercise = set.exercises.last;
          }
          // case: exercise is first in set and first rep
          else if (exIndex == 0 && rep == 0 && setIndex > 0) {
            _locPrevExercise = _workout.sets[setIndex - 1].exercises.last;
          } else {
            _locPrevExercise = null;
          }

          // announce next exercise
          if ((PrefService.getString('sound') == 'tts' &&
                  PrefService.getBool('tts_next_announce')) &&
              exercise.duration >= 10) {
            setMap[_currentTime + exercise.duration - 9] = () {
              TTSHelper.speak(
                  S.of(context).nextExercise(_locNextExercise.name));
            };
          } else if (_currentSecond > 10 && PrefService.getBool('ticks')) {
            SoundHelper.playBeepTick();
          }

          // set next set
          if (setIndex + 1 < _workout.sets.length) {
            _locNextSet = _workout.sets[setIndex + 1];
          }

          if (exercise.duration >= 10 && PrefService.getBool('halftime')) {
            setMap[(_currentTime + exercise.duration / 2).round()] = () {
              if (PrefService.getString('sound') == 'beep') {
                SoundHelper.playDouble();
              } else if (PrefService.getString('sound') == 'tts') {
                TTSHelper.speak(S.of(context).halfwayDone);
              }
            };
          }

          // countdown to next exercise
          setMap[_currentTime + exercise.duration - 3] = () {
            TTSHelper.speak('3');
            SoundHelper.playBeepLow();
          };

          setMap[_currentTime + exercise.duration - 2] = () {
            TTSHelper.speak('2');
            SoundHelper.playBeepLow();
          };

          setMap[_currentTime + exercise.duration - 1] = () {
            TTSHelper.speak('1');
            SoundHelper.playBeepLow();
          };

          // update display and announce current exercise
          setMap[_currentTime] = () {
            setState(() {
              _itemScrollController.scrollTo(
                index: exIndex - 1 > 0 ? exIndex - 1 : 0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
              );
              _remainingSeconds = exercise.duration;
              _currentSet = set;
              _prevExercise = _locPrevExercise;
              _nextExercise = _locNextExercise;
              _currentExercise = exercise;
              _nextSet = _locNextSet;
              _currentReps = rep;
              TTSHelper.speak(exercise.name);
              SoundHelper.playBeepHigh();
            });
          };
          _currentTime += exercise.duration;
        });
      }

      // announce completed workout
      _timetable[_currentTime] = () {
        _timerStop();
        TTSHelper.speak(S.of(context).workoutComplete);
        setState(() {
          _workoutDone = true;
          _currentExercise =
              Exercise(name: S.of(context).workoutComplete, duration: 1);
        });
      };

      _timetable.addAll(setMap);
    });
  }

  void _timerStart() {
    setState(() {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _timerTick();
      });
    });
  }

  void _timerTick() {
    setState(() {
      _currentSecond += 1;
      _remainingSeconds -= 1;

      if (_timetable.containsKey(_currentSecond)) {
        _timetable[_currentSecond]();
      } else if (_currentSecond > 10 && PrefService.getBool('ticks')) {
        SoundHelper.playBeepTick();
      }
    });
  }

  void _timerStop() {
    setState(() {
      _timer.cancel();
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
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );

    buildTimetable();
  }

  Widget _buildCurrentSetList(Set set) {
    if (set == null) return Container();

    return SizedBox(
      height: 217,
      child: ScrollablePositionedList.builder(
        itemBuilder: (context, index) {
          if (index < set.exercises.length) {
            return _buildSetItem(set.exercises[index],
                set.exercises.indexOf(_currentExercise) == index);
          } else {
            return null;
          }
        },
        itemCount: set.exercises.length,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
      ),
    );
  }

  Widget _buildNextSetList(Set set) {
    if (set == null) return Container();

    return SizedBox(
      height: 217,
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index < set.exercises.length) {
            return _buildSetItem(set.exercises[index],
                set.exercises.indexOf(_currentExercise) == index);
          } else {
            return null;
          }
        },
        itemCount: set.exercises.length,
        primary: false,
        shrinkWrap: true,
      ),
    );
  }

  Widget _buildSetItem(Exercise exercise, bool active) => ListTile(
        tileColor: active
            ? Theme.of(context).primaryColor
            : Theme.of(context).focusColor,
        title: Text(exercise.name),
        subtitle: Text(S
            .of(context)
            .durationWithTime(Utils.formatSeconds(exercise.duration))),
      );

  _WorkoutPageState(Workout workout) {
    _workout = workout;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_workout.title),
        ),
        bottomNavigationBar: BottomAppBar(
            shape: AutomaticNotchedShape(
                ContinuousRectangleBorder(), CircleBorder()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // left side of footer
                Expanded(
                    child: ListTile(
                  title: Text(S.of(context).exerciseOf(
                      _currentSet.exercises.indexOf(_currentExercise) +
                          1 +
                          (_currentReps * _currentSet.exercises.length),
                      _currentSet.exercises.length * _currentSet.repetitions)),
                  subtitle: Text(S
                      .of(context)
                      .repOf(_currentReps + 1, _currentSet.repetitions)),
                )),
                // right side of footer
                Expanded(
                    child: ListTile(
                  title: Text(
                    S.of(context).setOf(_workout.sets.indexOf(_currentSet) + 1,
                        _workout.sets.length),
                    textAlign: TextAlign.end,
                  ),
                  subtitle: Text(
                    S.of(context).durationLeft(
                        Utils.formatSeconds(
                            _workout.duration - _currentSecond + 10),
                        Utils.formatSeconds(_workout.duration + 10)),
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
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    LinearProgressIndicator(
                      value: _remainingSeconds /
                          (_currentSecond < 10
                              ? 10
                              : _currentExercise.duration),
                      minHeight: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).accentColor),
                    ),
                    Text(
                      '${_currentExercise.name}',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
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
                          padding: EdgeInsets.all(16.0),
                          child: Text(S.of(context).currentSet,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
                                title: Text(S.of(context).nextSet,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                subtitle: _nextSet != null
                                    ? Text(S
                                        .of(context)
                                        .countRepetitions(_nextSet.repetitions))
                                    : null,
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
              onPressed: () {
                skipBackward();
              },
              child: Icon(Icons.skip_previous),
            ),
            FloatingActionButton(
              heroTag: 'mainFAB',
              child: Icon(
                _timer != null && _timer.isActive
                    ? Icons.pause
                    : _workoutDone
                        ? Icons.replay
                        : Icons.play_arrow,
                size: 32,
              ),
              onPressed: () {
                if (_timer != null && _timer.isActive) {
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
              onPressed: () {
                skipForward();
              },
              child: Icon(Icons.skip_next),
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
                    FlatButton(
                      child: Text(S.of(context).no),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
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
