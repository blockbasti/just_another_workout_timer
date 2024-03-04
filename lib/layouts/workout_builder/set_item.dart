
import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/layouts/workout_builder/workout_builder.dart';

import '../../generated/l10n.dart';
import '../../utils/number_stepper.dart';
import '../../utils/utils.dart';
import '../../utils/workout.dart';
import 'exercise_list.dart';

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
