import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../utils/utils.dart';
import '../../utils/workout.dart';

class WorkoutRunnerSetItem extends StatelessWidget {
  const WorkoutRunnerSetItem(
      {super.key, required this.exercise, required this.active});

  final Exercise exercise;
  final bool active;

  @override
  Widget build(BuildContext context) => ListTile(
        tileColor: active
            ? Theme.of(context).primaryColor
            : Theme.of(context).focusColor,
        title: Text(exercise.name),
        subtitle: Text(S
            .of(context)
            .durationWithTime(Utils.formatSeconds(exercise.duration))),
      );
}
