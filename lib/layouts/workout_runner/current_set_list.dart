import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'set_item.dart';
import '../../utils/timetable.dart';
import '../../utils/workout.dart';

class CurrentSetList extends StatefulWidget {
  const CurrentSetList({super.key, required this.set, required this.timetable});

  final Set set;
  final Timetable timetable;

  @override
  State<CurrentSetList> createState() => _CurrentSetListState();
}

class _CurrentSetListState extends State<CurrentSetList> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    widget.timetable.itemScrollController = _itemScrollController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var list = ScrollablePositionedList.builder(
      itemBuilder: (context, index) => WorkoutRunnerSetItem(
          exercise: widget.set.exercises[index],
          active:
              widget.set.exercises.indexOf(widget.timetable.currentExercise) ==
                  index),
      itemCount: widget.set.exercises.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      shrinkWrap: true,
    );

    if (!Prefs.getBool('expanded_setlist', false)) {
      return SizedBox(
        height: 217,
        child: list,
      );
    } else {
      return list;
    }
  }
}
