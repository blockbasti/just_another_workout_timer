import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../utils/number_stepper.dart';
import '../utils/storage_helper.dart';
import '../utils/utils.dart';
import '../utils/workout.dart';

class BuilderPage extends StatefulWidget {
  final Workout workout;
  final bool newWorkout;

  const BuilderPage({
    super.key,
    required this.workout,
    required this.newWorkout,
  });

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

  void saveWorkout() async {
    if (_workout.title == '') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(S.of(context).enterWorkoutName),
        ),
      );
      return;
    }

    setState(() {
      _workout.cleanUp();
    });

    if ((_newWorkout && await workoutExists(_workout.title)) ||
        (!_newWorkout &&
            _oldTitle != _workout.title &&
            await workoutExists(_workout.title))) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(S.of(context).overwriteExistingWorkout),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).no),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(S.of(context).yes),
              onPressed: () async {
                await deleteWorkout(_oldTitle);
                writeWorkout(_workout);
                _oldTitle = _workout.title;
                _newWorkout = false;
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      writeWorkout(_workout);
      _newWorkout = false;
      if (!context.mounted) return;
      Fluttertoast.showToast(
        msg: S.of(context).saved,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _addExercise(int setIndex, bool isRest) {
    setState(() {
      _workout.sets[setIndex].exercises.add(
        Exercise(
          name: isRest ? S.of(context).rest : S.of(context).exercise,
          duration: _lastDuration,
        ),
      );
      _dirty = true;
    });
  }

  void _deleteExercise(int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises.removeAt(exIndex);
      _dirty = true;
    });
  }

  Widget _buildSetList() => ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          setState(() {
            var set = _workout.sets.removeAt(oldIndex);
            _workout.sets.insert(newIndex, set);
          });
        },
        children: _workout.sets
            .asMap()
            .map((index, set) => MapEntry(index, _buildSetItem(set, index)))
            .values
            .toList(),
      );

  Widget _buildSetItem(Set set, int index) =>
      ReorderableDelayedDragStartListener(
        index: index,
        key: Key(set.id),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(
                        S.of(context).setIndex(_workout.sets.indexOf(set) + 1),
                      ),
                      subtitle: Text(Utils.formatSeconds(set.duration)),
                    ),
                  ),
                  Text(S.of(context).repetitions),
                  NumberStepper(
                    lowerLimit: 1,
                    upperLimit: 99,
                    largeSteps: false,
                    formatNumber: false,
                    value: set.repetitions,
                    valueChanged: (repetitions) {
                      setState(() {
                        set.repetitions = repetitions;
                        _dirty = true;
                      });
                    },
                  ),
                ],
              ),
              _buildExerciseList(set, index),
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fitness_center),
                        tooltip: S.of(context).addExercise,
                        onPressed: () {
                          _addExercise(index, false);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause_circle_filled),
                        tooltip: S.of(context).addRest,
                        onPressed: () {
                          _addExercise(index, true);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: S.of(context).deleteSet,
                        onPressed: () {
                          _deleteSet(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: S.of(context).duplicate,
                        onPressed: () => _duplicateSet(index),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildExerciseList(Set set, int setIndex) => ReorderableListView(
        shrinkWrap: true,
        primary: false,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          setState(() {
            var ex = _workout.sets[setIndex].exercises.removeAt(oldIndex);
            _workout.sets[setIndex].exercises.insert(newIndex, ex);
          });
        },
        children: set.exercises
            .asMap()
            .keys
            .map(
              (index) => _buildExerciseItem(
                setIndex,
                index,
                set.exercises[index].name,
              ),
            )
            .toList(),
      );

  Widget _buildExerciseItem(int setIndex, int exIndex, String name) =>
      ReorderableDelayedDragStartListener(
        index: exIndex,
        key: Key(_workout.sets[setIndex].exercises[exIndex].id),
        child: Card(
          child: Row(
            key: Key(_workout.sets[setIndex].exercises[exIndex].id),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ReorderableDragStartListener(
                  index: exIndex,
                  child: const Icon(Icons.drag_handle),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: name,
                      maxLength: 30,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: S.of(context).exercise,
                      ),
                      onChanged: (text) {
                        _workout.sets[setIndex].exercises[exIndex].name = text;
                        _dirty = true;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: S.of(context).deleteExercise,
                          onPressed: () {
                            _deleteExercise(setIndex, exIndex);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: S.of(context).duplicate,
                          onPressed: () =>
                              _duplicateExercise(setIndex, exIndex),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NumberStepper(
                    lowerLimit: 0,
                    upperLimit: 10800,
                    largeSteps: true,
                    formatNumber: true,
                    value: _workout.sets[setIndex].exercises[exIndex].duration,
                    valueChanged: (duration) {
                      setState(() {
                        _workout.sets[setIndex].exercises[exIndex].duration =
                            duration;
                        _dirty = true;
                        _lastDuration = duration;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (!_dirty) {
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
            ),
          );

          return value!;
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
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: S.of(context).saveWorkout,
                onPressed: saveWorkout,
              ),
            ],
          ),
          body: Center(
            child: _buildSetList(),
          ),
          bottomNavigationBar: BottomAppBar(
            height: 50,
            elevation: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S
                      .of(context)
                      .durationWithTime(Utils.formatSeconds(_workout.duration)),
                ),
              ],
            ),
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
