import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_another_workout_timer/layouts/workout_builder/set_list.dart';
import 'package:uuid/uuid.dart';

import '../../generated/l10n.dart';
import '../../utils/storage_helper.dart';
import '../../utils/utils.dart';
import '../../utils/workout.dart';

class BuilderPage extends StatefulWidget {
  final Workout workout;
  final bool newWorkout;

  const BuilderPage({Key? key, required this.workout, required this.newWorkout})
      : super(key: key);

  @override
  BuilderPageState createState() =>
      BuilderPageState(workout, newWorkout: newWorkout);
}

/// page allowing a user to create a workout
class BuilderPageState extends State<BuilderPage> {
  late Workout _workout;
  late String _oldTitle;
  late bool _newWorkout;
  bool _dirty = false;
  int _lastDuration = 30;

  BuilderPageState(Workout workout, {required bool newWorkout}) {
    _workout = workout;
    _oldTitle = _workout.title;
    _newWorkout = newWorkout;
  }

  void _addSet() {
    setState(() {
      _workout.sets.add(Set(exercises: []));
      _dirty = true;
    });
  }

  void _deleteSet(int index) {
    setState(() {
      _workout.sets.removeAt(index);
      _dirty = true;
    });
  }

  void _duplicateSet(int index) {
    var newSet = Set.fromJson(_workout.sets[index].toJson());
    newSet.id = const Uuid().v4();
    setState(() {
      _workout.sets.insert(index, newSet);
      _dirty = true;
    });
  }

  void _duplicateExercise(int setIndex, int exIndex) {
    var newEx =
        Exercise.fromJson(_workout.sets[setIndex].exercises[exIndex].toJson());
    newEx.id = const Uuid().v4();
    setState(() {
      _workout.sets[setIndex].exercises.insert(exIndex, newEx);
      _dirty = true;
    });
  }

  void _onExerciseTextChanged(String text, int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises[exIndex].name = text;
      _dirty = true;
    });
  }

  void _onExerciseDurationChanged(int duration, int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises[exIndex].duration = duration;
      _dirty = true;
    });
  }

  void _onSetRepetitionsChanged(int repetitions, int setIndex) {
    setState(() {
      _workout.sets[setIndex].repetitions = repetitions;
      _dirty = true;
    });
  }

  void _addExercise(int setIndex, bool isRest) {
    setState(() {
      _workout.sets[setIndex].exercises.add(Exercise(
          name: isRest ? S.of(context).rest : S.of(context).exercise,
          duration: _lastDuration));
      _dirty = true;
    });
  }

  void _deleteExercise(int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises.removeAt(exIndex);
      _dirty = true;
    });
  }

  void saveWorkout() async {
    if (_workout.title == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(S.of(context).enterWorkoutName),
              ));
      return;
    }

    setState(() {
      _workout.cleanUp();
    });

    if ((_newWorkout && await workoutExists(_workout.title)) ||
        (!_newWorkout &&
            _oldTitle != _workout.title &&
            await workoutExists(_workout.title))) {
      if (!mounted) return;
      // ask if the user wants to overwrite the existing workout
      // if they say no, do not exit the screen
      bool? exitScreen = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(S.of(context).overwriteExistingWorkout),
                actions: <Widget>[
                  TextButton(
                    child: Text(S.of(context).no),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(S.of(context).yes),
                    onPressed: () async {
                      await deleteWorkout(_oldTitle);
                      writeWorkout(_workout);
                      _oldTitle = _workout.title;
                      _newWorkout = false;
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ));
      if (exitScreen == false) return;
    } else {
      writeWorkout(_workout);
      _newWorkout = false;
      Fluttertoast.showToast(
          msg: S.of(context).saved,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_dirty,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;
          // if the user has made changes, ask if they want to exit
          final yesExit = await showDialog<bool>(
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

          if (yesExit == true && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 74,
            elevation: 1,
            title: TextFormField(
                initialValue: _workout.title,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                maxLines: 1,
                onChanged: (name) {
                  _workout.title = name;
                  setState(() {
                    _dirty = true;
                  });
                },
                decoration: InputDecoration(
                  labelText: S.of(context).name,
                )),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: S.of(context).saveWorkout,
                onPressed: saveWorkout,
              )
            ],
          ),
          body: Center(
            child: SetList(
              workout: _workout,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  var set = _workout.sets.removeAt(oldIndex);
                  _workout.sets.insert(newIndex, set);
                });
              },
              onReorderExercise: (oldIndex, newIndex, setIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  var ex = _workout.sets[setIndex].exercises.removeAt(oldIndex);
                  _workout.sets[setIndex].exercises.insert(newIndex, ex);
                });
              },
              deleteSet: _deleteSet,
              duplicateSet: _duplicateSet,
              deleteExercise: _deleteExercise,
              duplicateExercise: _duplicateExercise,
              addExercise: _addExercise,
              onExerciseTextChanged: _onExerciseTextChanged,
              onExerciseDurationChanged: _onExerciseDurationChanged,
              onSetRepetitionsChanged: _onSetRepetitionsChanged,
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            height: 50,
            elevation: 1,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S
                      .of(context)
                      .durationWithTime(Utils.formatSeconds(_workout.duration)))
                ]),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'mainFAB',
            onPressed: _addSet,
            tooltip: S.of(context).addSet,
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        ),
      );
}
