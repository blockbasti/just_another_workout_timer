import 'package:flutter/material.dart';

import 'set_item.dart';
import '../../utils/timetable.dart';
import '../../utils/workout.dart';

class NextSetList extends StatelessWidget {
  const NextSetList({super.key, required this.set, required this.timetable});

  final Set set;
  final Timetable timetable;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 217,
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index < set.exercises.length) {
              return WorkoutRunnerSetItem(
                  exercise: set.exercises[index],
                  active: set.exercises.indexOf(timetable.currentExercise) ==
                      index);
            } else {
              return Container();
            }
          },
          itemCount: set.exercises.length,
          primary: false,
          shrinkWrap: true,
        ),
      );
}
