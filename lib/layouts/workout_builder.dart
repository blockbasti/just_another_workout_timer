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
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
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
                  ));

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

class SetList extends StatelessWidget {
  const SetList(
      {super.key,
      required this.workout,
      required this.onReorder,
      required this.onReorderExercise,
      required this.deleteSet,
      required this.duplicateSet,
      required this.deleteExercise,
      required this.duplicateExercise,
      required this.addExercise,
      required this.onExerciseTextChanged,
      required this.onExerciseDurationChanged,
      required this.onSetRepetitionsChanged});

  final Workout workout;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int oldIndex, int newIndex, int setIndex) onReorderExercise;

  final Function(int index) deleteSet;
  final Function(int index) duplicateSet;

  final Function(int index, int exIndex) deleteExercise;
  final Function(int index, int exIndex) duplicateExercise;
  final Function(int index, bool isRest) addExercise;

  final Function(String text, int setIndex, int exIndex) onExerciseTextChanged;
  final Function(int duration, int setIndex, int exIndex)
      onExerciseDurationChanged;
  final Function(int repetitions, int setIndex) onSetRepetitionsChanged;

  @override
  Widget build(BuildContext context) => ReorderableListView(
        onReorder: onReorder,
        children: workout.sets
            .asMap()
            .map((index, set) => MapEntry(
                index,
                SetItem(
                  key: Key(set.id),
                  set: set,
                  index: index,
                  workout: workout,
                  onReorder: onReorderExercise,
                  deleteSet: deleteSet,
                  duplicateSet: duplicateSet,
                  deleteExercise: deleteExercise,
                  duplicateExercise: duplicateExercise,
                  addExercise: addExercise,
                  onExerciseTextChanged: onExerciseTextChanged,
                  onExerciseDurationChanged: onExerciseDurationChanged,
                  onSetRepetitionsChanged: onSetRepetitionsChanged,
                )))
            .values
            .toList(),
      );
}

class SetItem extends StatelessWidget {
  const SetItem(
      {super.key,
      required this.index,
      required this.set,
      required this.workout,
      required this.onReorder,
      required this.deleteSet,
      required this.duplicateSet,
      required this.deleteExercise,
      required this.duplicateExercise,
      required this.addExercise,
      required this.onExerciseTextChanged,
      required this.onExerciseDurationChanged,
      required this.onSetRepetitionsChanged});

  final int index;
  final Set set;
  final Workout workout;
  final Function(int oldIndex, int newIndex, int setIndex) onReorder;

  final Function(int index) deleteSet;
  final Function(int index) duplicateSet;

  final Function(int index, int exIndex) deleteExercise;
  final Function(int index, int exIndex) duplicateExercise;
  final Function(int index, bool isRest) addExercise;

  final Function(String text, int setIndex, int exIndex) onExerciseTextChanged;
  final Function(int duration, int setIndex, int exIndex)
      onExerciseDurationChanged;
  final Function(int repetitions, int setIndex) onSetRepetitionsChanged;

  @override
  Widget build(BuildContext context) => ReorderableDelayedDragStartListener(
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
                    index: index, child: const Icon(Icons.drag_handle)),
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    S.of(context).setIndex(workout.sets.indexOf(set) + 1),
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
                  valueChanged: (repetitions) =>
                      onSetRepetitionsChanged(repetitions, index))
            ],
          ),
          ExerciseList(
            workout: workout,
            set: set,
            setIndex: index,
            onReorder: onReorder,
            deleteExercise: deleteExercise,
            duplicateExercise: duplicateExercise,
            addExercise: addExercise,
            onExerciseTextChanged: onExerciseTextChanged,
            onExerciseDurationChanged: onExerciseDurationChanged,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.fitness_center),
                    tooltip: S.of(context).addExercise,
                    onPressed: () {
                      addExercise(index, false);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause_circle_filled),
                    tooltip: S.of(context).addRest,
                    onPressed: () {
                      addExercise(index, true);
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
                        deleteSet(index);
                      }),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: S.of(context).duplicate,
                    onPressed: () => duplicateSet(index),
                  ),
                ],
              ),
            ],
          )
        ],
      )));
}

class ExerciseList extends StatelessWidget {
  const ExerciseList(
      {super.key,
      required this.workout,
      required this.set,
      required this.setIndex,
      required this.onReorder,
      required this.deleteExercise,
      required this.duplicateExercise,
      required this.addExercise,
      required this.onExerciseTextChanged,
      required this.onExerciseDurationChanged});

  final Workout workout;
  final Set set;
  final int setIndex;
  final Function(int oldIndex, int newIndex, int setIndex) onReorder;
  final Function(int setIndex, int exIndex) deleteExercise;
  final Function(int setIndex, int exIndex) duplicateExercise;
  final Function(int setIndex, bool isRest) addExercise;
  final Function(String text, int setIndex, int exIndex) onExerciseTextChanged;
  final Function(int duration, int setIndex, int exIndex)
      onExerciseDurationChanged;

  @override
  Widget build(BuildContext context) => ReorderableListView(
        shrinkWrap: true,
        primary: false,
        onReorder: (oldIndex, newIndex) =>
            onReorder(oldIndex, newIndex, setIndex),
        children: set.exercises
            .asMap()
            .keys
            .map((index) => ExerciseItem(
                key: Key(set.exercises[index].id),
                workout: workout,
                setIndex: setIndex,
                exIndex: index,
                name: set.exercises[index].name,
                onExerciseTextChanged: onExerciseTextChanged,
                onExerciseDurationChanged: onExerciseDurationChanged,
                deleteExercise: deleteExercise,
                duplicateExercise: duplicateExercise))
            .toList(),
      );
}

class ExerciseItem extends StatelessWidget {
  const ExerciseItem(
      {super.key,
      required this.workout,
      required this.setIndex,
      required this.exIndex,
      required this.name,
      required this.onExerciseTextChanged,
      required this.onExerciseDurationChanged,
      required this.deleteExercise,
      required this.duplicateExercise});

  final Workout workout;
  final int setIndex;
  final int exIndex;
  final String name;
  final Function(String text, int setIndex, int exIndex) onExerciseTextChanged;
  final Function(int duration, int setIndex, int exIndex)
      onExerciseDurationChanged;
  final Function(int setIndex, int exIndex) deleteExercise;
  final Function(int setIndex, int exIndex) duplicateExercise;

  @override
  Widget build(BuildContext context) => ReorderableDelayedDragStartListener(
      index: exIndex,
      key: Key(workout.sets[setIndex].exercises[exIndex].id),
      child: Card(
        child: Row(
          key: Key(workout.sets[setIndex].exercises[exIndex].id),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ReorderableDragStartListener(
                  index: exIndex, child: const Icon(Icons.drag_handle)),
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
                  onChanged: (text) =>
                      onExerciseTextChanged(text, setIndex, exIndex),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: S.of(context).deleteExercise,
                      onPressed: () {
                        deleteExercise(setIndex, exIndex);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: S.of(context).duplicate,
                      onPressed: () => duplicateExercise(setIndex, exIndex),
                    ),
                  ],
                )
              ],
            )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NumberStepper(
                  lowerLimit: 0,
                  upperLimit: 10800,
                  largeSteps: true,
                  formatNumber: true,
                  value: workout.sets[setIndex].exercises[exIndex].duration,
                  valueChanged: (duration) =>
                      onExerciseDurationChanged(duration, setIndex, exIndex),
                ),
              ],
            ),
          ],
        ),
      ));
}
