import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/TTSHelper.dart';
import 'package:just_another_workout_timer/Utils.dart';
import 'package:just_another_workout_timer/Workout.dart';

class WorkoutPage extends StatefulWidget {
  final Workout workout;

  WorkoutPage({Key key, @required this.workout}) : super(key: key);

  @override
  _WorkoutPageState createState() => _WorkoutPageState(workout);
}

class _WorkoutPageState extends State<WorkoutPage> {
  Timer _timer;
  Workout _workout;

  Set _currentSet = Set(exercises: [], repetitions: 1);
  Exercise _currentExercise = Exercise(duration: 0, name: '');
  int _currentReps = 0;

  Set _nextSet;
  Exercise _nextExercise;

  int _remainingSeconds = 10;
  int _currentSecond = 0;

  bool _workoutDone = false;

  Map<int, Function> _timetable = new SplayTreeMap();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    buildTimetable();
  }

  void buildTimetable() {
    setState(() {
      _currentSet = _workout.sets[0];
      _currentExercise = _workout.sets[0].exercises[0];
    });

    int _currentTime = 10;

    _timetable[1] = () {
      TTSHelper.speak('First: ${_workout.sets[0].exercises[0].name}');
    };

    _timetable[7] = () {
      TTSHelper.speak('3');
    };

    _timetable[8] = () {
      TTSHelper.speak('2');
    };

    _timetable[9] = () {
      TTSHelper.speak('1');
    };

    _workout.sets.asMap().forEach((setIndex, set) {
      Map<int, Function> setMap = new Map();

      for (int rep = 0; rep < set.repetitions; rep++) {
        set.exercises.asMap().forEach((exIndex, exercise) {
          Set _locNextSet;
          Exercise _locNextExercise;

          try {
            if (exercise.duration > 10) {
              // case: exercise is somewhere in set
              if (exIndex + 1 < set.exercises.length) {
                setMap[_currentTime + exercise.duration - 10] = () {
                  TTSHelper.speak('Next: ${set.exercises[exIndex + 1].name}');
                };
                if (setIndex + 1 < _workout.sets.length) {
                  _locNextSet = _workout.sets[setIndex + 1];
                }
                _locNextExercise = set.exercises[exIndex + 1];
              }
              // case: exercise is last in set but set has remaining reps
              else if (exIndex + 1 == set.exercises.length &&
                  rep < set.repetitions - 1) {
                setMap[_currentTime + exercise.duration - 10] = () {
                  TTSHelper.speak('Next: ${set.exercises[0].name}');
                };
                _locNextExercise = set.exercises[0];
              }
              // case: exercise is last in set and set is completed
              else if (setIndex + 1 < _workout.sets.length) {
                setMap[_currentTime + exercise.duration - 10] = () {
                  TTSHelper.speak(
                      'Next: ${_workout.sets[setIndex + 1].exercises[0].name}');
                };
                _locNextExercise = _workout.sets[setIndex + 1].exercises[0];
              }
            }
          } catch (e) {}

          if (setIndex + 1 < _workout.sets.length) {
            _locNextSet = _workout.sets[setIndex + 1];
          }

          setMap[_currentTime + exercise.duration - 3] = () {
            TTSHelper.speak('3');
          };

          setMap[_currentTime + exercise.duration - 2] = () {
            TTSHelper.speak('2');
          };

          setMap[_currentTime + exercise.duration - 1] = () {
            TTSHelper.speak('1');
          };

          setMap[_currentTime] = () {
            setState(() {
              _remainingSeconds = exercise.duration;
              _currentSet = set;
              _currentExercise = exercise;
              _nextSet = _locNextSet;
              _nextExercise = _locNextExercise;
              _currentReps = rep;
              TTSHelper.speak(exercise.name);
            });
          };
          _currentTime += exercise.duration;
        });
      }
      _timetable[_currentTime] = () {
        _timerStop();
        TTSHelper.speak('Workout complete');
        setState(() {
          _workoutDone = true;
          _currentExercise = Exercise(name: 'Workout complete!', duration: 0);
        });
      };

      _timetable.addAll(setMap);
    });
  }

  void _timerStart() {
    buildTimetable();
    setState(() {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _currentSecond += 1;
          _remainingSeconds -= 1;

          if (_timetable.containsKey(_currentSecond)) {
            _timetable[_currentSecond]();
          }
        });
      });
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
      _nextExercise = Exercise(duration: 0, name: '');

      _remainingSeconds = 10;
      _currentSecond = 0;
    });
    buildTimetable();
  }

  Widget _buildSetList(Set set) {
    if (set == null) return Container();
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          if (index < set.exercises.length) {
            return _buildSetItem(set.exercises[index],
                set.exercises.indexOf(_currentExercise) == index);
          } else
            return null;
        });
  }

  Widget _buildSetItem(Exercise exercise, bool active) {
    return ListTile(
      tileColor: active
          ? Theme.of(context).focusColor
          : Theme.of(context).primaryColor,
      title: Text(exercise.name),
      subtitle: Text('Duration: ${Utils.formatSeconds(exercise.duration)}'),
    );
  }

  _WorkoutPageState(Workout workout) {
    _workout = workout;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(_workout.title),
          ),
          bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: ListTile(
                    title: Text(
                        'Exercise ${_currentSet.exercises.indexOf(_currentExercise) + 1 * (_currentReps + 1)} of ${_currentSet.exercises.length * _currentSet.repetitions}'),
                    subtitle: Text(
                        'Repetition ${_currentReps + 1} of ${_currentSet.repetitions}'),
                  )),
                  Expanded(
                      child: ListTile(
                    title: Text(
                      'Set ${_workout.sets.indexOf(_currentSet) + 1} of ${_workout.sets.length}',
                      textAlign: TextAlign.end,
                    ),
                    subtitle: Text(
                      '${_workout.duration - _currentSecond + 10} of ${_workout.duration + 10} seconds left',
                      textAlign: TextAlign.end,
                    ),
                  ))
                ],
              )),
          body: Column(
            children: [
              Card(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '${Utils.formatSeconds(_remainingSeconds)}',
                        style: TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_currentExercise.name}',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Current set',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _buildSetList(_currentSet),
                  ],
                ),
              ),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Next set',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _buildSetList(_nextSet),
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              _timer != null && _timer.isActive
                  ? Icons.pause
                  : _workoutDone
                      ? Icons.replay
                      : Icons.play_arrow,
              size: 32,
            ),
            onPressed: () {
              if (_timer != null && _timer.isActive)
                _timerStop();
              else if (_workoutDone)
                _resetWorkout();
              else
                _timerStart();
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
        onWillPop: () async {
          final value = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text('Are you sure you want to exit?'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text('Yes, exit'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              });

          return value == true;
        });
  }
}
