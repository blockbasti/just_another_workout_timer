
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n.dart';
import '../../utils/number_stepper.dart';
import '../../utils/workout.dart';

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
