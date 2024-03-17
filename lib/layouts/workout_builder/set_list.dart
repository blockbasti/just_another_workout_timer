
import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/layouts/workout_builder/set_item.dart';

import '../../utils/workout.dart';

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
