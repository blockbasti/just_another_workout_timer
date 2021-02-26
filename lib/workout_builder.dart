import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'generated/l10n.dart';
import 'number_stepper.dart';
import 'storage_helper.dart';
import 'utils.dart';
import 'workout.dart';

class BuilderPage extends StatefulWidget {
  final Workout workout;
  final bool newWorkout;

  BuilderPage({Key key, @required this.workout, @required this.newWorkout})
      : super(key: key);

  @override
  _BuilderPageState createState() =>
      _BuilderPageState(workout, newWorkout: newWorkout);
}

/// page allowing a user to create a workout
class _BuilderPageState extends State<BuilderPage> {
  Workout _workout;
  String _oldTitle;
  bool _newWorkout;

  _BuilderPageState(Workout workout, {bool newWorkout}) {
    _workout = workout;
    _oldTitle = _workout.title;
    _newWorkout = newWorkout;
  }

  void _addSet() {
    setState(() {
      _workout.sets.add(Set.empty());
    });
  }

  void _deleteSet(int index) {
    setState(() {
      _workout.sets.removeAt(index);
    });
  }

  void _duplicateSet(int index) {
    setState(() {
      _workout.sets.insert(index, Set.fromJson( _workout.sets[index].toJson()));
    });
  }

  void _duplicateExercise(int setIndex, int exIndex){
    setState(() {
      _workout.sets[setIndex].exercises.insert(exIndex, Exercise.fromJson(_workout.sets[setIndex].exercises[exIndex].toJson()));
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
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(S.of(context).overwriteExistingWorkout),
                actions: <Widget>[
                  FlatButton(
                    child: Text(S.of(context).no),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text(S.of(context).yes),
                    onPressed: () async {
                      await deleteWorkout(_oldTitle);
                      writeWorkout(_workout);
                      _oldTitle = _workout.title;
                      _newWorkout = false;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
    } else {
      writeWorkout(_workout);
      _newWorkout = false;
    }
  }

  void _addExercise(int setIndex, bool isRest) {
    setState(() {
      _workout.sets[setIndex].exercises.add(
          Exercise(
              name: isRest ? S.of(context).rest : S.of(context).exercise,
              duration: 30
          ));
    });
  }

  void _deleteExercise(int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises.removeAt(exIndex);
    });
  }

  Widget _buildSetList() => ListView.builder(
        itemBuilder: (context, index) {
          if (index < _workout.sets.length) {
            return _buildSetItem(_workout.sets[index], index);
          } else {
            return null;
          }
        },
      );

  Widget _buildSetItem(Set set, int index) => Card(
      key: Key(set.toRawJson()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: S.of(context).deleteSet,
                  onPressed: () {
                    _deleteSet(index);
                  }),
              Expanded(
                child: ListTile(
                  title: Text(
                    S.of(context).setIndex(_workout.sets.indexOf(set) + 1),
                  ),
                  subtitle: Text('${Utils.formatSeconds(set.duration)}'),
                ),
              ),
              Text(S.of(context).repetitions),
              NumberStepper(
                  lowerLimit: 0,
                  upperLimit: 99,
                  stepValue: 1,
                  formatNumber: false,
                  value: set.repetitions,
                  valueChanged: (repetitions) {
                    setState(() {
                      set.repetitions = repetitions;
                    });
                  })
            ],
          ),
          _buildExerciseList(set, index),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.fitness_center),
                    tooltip: S.of(context).addExercise,
                    onPressed: () {
                      _addExercise(index, false);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.pause_circle_filled),
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
                    icon: Icon(Icons.copy),
                    tooltip: S.of(context).duplicate,
                    onPressed: () =>_duplicateSet(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    tooltip: S.of(context).moveSetUp,
                    onPressed: index - 1 >= 0
                        ? () {
                            setState(() {
                              _workout.moveSet(index, moveUp: true);
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    tooltip: S.of(context).moveSetDown,
                    onPressed: index + 1 < _workout.sets.length
                        ? () {
                            setState(() {
                              _workout.moveSet(index, moveUp: false);
                            });
                          }
                        : null,
                  )
                ],
              ),
            ],
          )
        ],
      ));

  Widget _buildExerciseList(Set set, int setIndex) => ListView.builder(
      shrinkWrap: true,
      primary: false,
      itemBuilder: (context, index) {
        if (index < _workout.sets[setIndex].exercises.length) {
          return _buildExerciseItem(setIndex, index, set.exercises[index].name);
        } else {
          return null;
        }
      });

  Widget _buildExerciseItem(int setIndex, int exIndex, String name) => Card(
        color: Theme.of(context).backgroundColor,
        child: Row(
          key: Key(_workout.sets[setIndex].exercises[exIndex].toRawJson()),
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              tooltip: S.of(context).deleteExercise,
              onPressed: () {
                _deleteExercise(setIndex, exIndex);
              },
            ),
            Expanded(
                flex: 1,
                child: TextFormField(
                  initialValue: name,
                  maxLength: 30,
                  maxLengthEnforced: true,
                  inputFormatters: [LengthLimitingTextInputFormatter(30)],
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: S.of(context).exercise,
                  ),
                  onChanged: (text) {
                    _workout.sets[setIndex].exercises[exIndex].name = text;
                  },
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NumberStepper(
                  lowerLimit: 0,
                  upperLimit: 995,
                  stepValue: 5,
                  formatNumber: true,
                  value: _workout.sets[setIndex].exercises[exIndex].duration,
                  valueChanged: (duration) {
                    setState(() {
                      _workout.sets[setIndex].exercises[exIndex].duration =
                          duration;
                    });
                  },
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_upward),
                      padding: EdgeInsets.zero,
                      tooltip: S.of(context).moveExerciseUp,
                      onPressed: exIndex - 1 >= 0
                          ? () {
                              setState(() {
                                _workout.sets[setIndex]
                                    .moveExercise(exIndex, moveUp: true);
                              });
                            }
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_downward),
                      padding: EdgeInsets.zero,
                      tooltip: S.of(context).moveExerciseDown,
                      onPressed:
                          exIndex + 1 < _workout.sets[setIndex].exercises.length
                              ? () {
                                  setState(() {
                                    _workout.sets[setIndex]
                                        .moveExercise(exIndex, moveUp: false);
                                  });
                                }
                              : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      tooltip: S.of(context).duplicate,
                      onPressed: () =>_duplicateExercise(setIndex, exIndex),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
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
        },
        child: Scaffold(
          appBar: AppBar(
            title: TextFormField(
                initialValue: _workout.title,
                maxLength: 30,
                maxLengthEnforced: true,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                maxLines: 1,
                onChanged: (name) {
                  _workout.title = name;
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
            child: _buildSetList(),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'mainFAB',
            onPressed: _addSet,
            tooltip: S.of(context).addSet,
            child: Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      );
}
