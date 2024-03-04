import 'package:flutter/material.dart';

import '../../utils/workout.dart';
import 'exercise_item.dart';

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
