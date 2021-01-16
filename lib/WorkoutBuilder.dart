import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/NumberStepper.dart';
import 'package:just_another_workout_timer/StorageHelper.dart';
import 'package:just_another_workout_timer/Workout.dart';

class BuilderPage extends StatefulWidget {
  final Workout workout;

  BuilderPage({Key key, @required this.workout}) : super(key: key);

  @override
  _BuilderPageState createState() => _BuilderPageState(workout);
}

class _BuilderPageState extends State<BuilderPage> {
  Workout _workout;
  String _oldTitle;

  _BuilderPageState(Workout workout) {
    _workout = workout;
    _oldTitle = _workout.title;
  }

  void _addSet() {
    setState(() {
      _workout.sets.add(Set.withReps(1));
    });
  }

  void _deleteSet(int index) {
    setState(() {
      _workout.sets.removeAt(index);
    });
  }

  void _addExercise(int setIndex, bool isRest) {
    setState(() {
      _workout.sets[setIndex].exercises
          .add(Exercise.withName(isRest ? 'Rest' : 'Exercise'));
    });
  }

  void _deleteExercise(int setIndex, int exIndex) {
    setState(() {
      _workout.sets[setIndex].exercises.removeAt(exIndex);
    });
  }

  Widget _buildSetList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index < _workout.sets.length) {
          return _buildSetItem(index);
        } else
          return null;
      },
    );
  }

  Widget _buildSetItem(int index) {
    return Card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Delete set',
                onPressed: () {
                  _deleteSet(index);
                }),
            Expanded(
              child: ListTile(
                title: Text(
                  'Set ${index + 1}',
                ),
                subtitle: Text('${_workout.sets[index].duration} seconds'),
              ),
            ),
            NumberStepper(
                lowerLimit: 0,
                upperLimit: 99,
                stepValue: 1,
                suffix: 'x',
                value: _workout.sets[index].repetitions,
                valueChanged: (int repetitions) {
                  _workout.sets[index].repetitions = repetitions;
                })
          ],
        ),
        _buildExerciseList(index),
        ButtonBar(
          alignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.fitness_center),
              tooltip: 'Add exercise',
              onPressed: () {
                _addExercise(index, false);
              },
            ),
            IconButton(
              icon: Icon(Icons.pause_circle_filled),
              tooltip: 'Add rest',
              onPressed: () {
                _addExercise(index, true);
              },
            )
          ],
        )
      ],
    ));
  }

  Widget _buildExerciseList(int setIndex) {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          if (index < _workout.sets[setIndex].exercises.length) {
            return _buildExerciseItem(
                setIndex, index, _workout.sets[setIndex].exercises[index].name);
          } else
            return null;
        });
  }

  Widget _buildExerciseItem(int setIndex, int exIndex, String name) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Delete exercise',
          onPressed: () {
            _deleteExercise(setIndex, exIndex);
          },
        ),
        Expanded(
            child: TextFormField(
          initialValue: name,
          decoration: InputDecoration(
            labelText: 'Exercise',
          ),
          onChanged: (text) {
            _workout.sets[setIndex].exercises[exIndex].name = text;
          },
        )),
        Expanded(
          child: NumberStepper(
            lowerLimit: 0,
            upperLimit: 995,
            stepValue: 5,
            suffix: 'sec',
            value: _workout.sets[setIndex].exercises[exIndex].duration,
            valueChanged: (int duration) {
              _workout.sets[setIndex].exercises[exIndex].duration = duration;
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
              initialValue: _workout.title,
              validator: (String value) {
                return value == '' ? 'Please enter a name!' : null;
              },
              onChanged: (String name) {
                _workout.title = name;
              },
              decoration: InputDecoration(
                labelText: 'Name',
              )),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save workout',
              onPressed: () {
                StorageHelper.deleteWorkout(_oldTitle);
                StorageHelper.writeWorkout(_workout);
                _oldTitle = _workout.title;
              },
            )
          ],
        ),
        body: Center(
          child: _buildSetList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addSet,
          tooltip: 'Add Set',
          child: Icon(Icons.add),
        ));
  }
}
