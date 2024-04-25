import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/utils/timetable.dart';
import 'package:prefs/prefs.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../generated/l10n.dart';
import '../utils/utils.dart';
import '../utils/workout.dart';

class WorkoutPage extends StatelessWidget {
  final Workout workout;

  const WorkoutPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => Timetable(context, workout),
        child: Consumer<Timetable>(
          builder: (context, timetable, child) =>
              WorkoutPageContent(workout: workout, timetable: timetable),
        ),
      );
}

/// page to do a workout
class WorkoutPageContent extends StatefulWidget {
  final Workout workout;
  final Timetable timetable;

  const WorkoutPageContent({
    super.key,
    required this.workout,
    required this.timetable,
  });

  @override
  WorkoutPageState createState() => WorkoutPageState();
}

class WorkoutPageState extends State<WorkoutPageContent> {
  late final Workout _workout;
  late final Timetable timetable;

  WorkoutPageState();

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void dispose() {
    timetable.timerStop();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
    timetable = widget.timetable;
    timetable.itemScrollController = _itemScrollController;
    if (Prefs.getBool('wakelock', true)) WakelockPlus.enable();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      timetable.buildTimetable();
    });
  }

  Widget _buildCurrentSetList(Set? set) {
    if (set == null) return Container();

    var list = ScrollablePositionedList.builder(
      itemBuilder: (context, index) => _buildSetItem(
        set.exercises[index],
        set.exercises.indexOf(timetable.currentExercise) == index,
      ),
      itemCount: set.exercises.length,
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

  Widget _buildNextSetList(Set? set) {
    if (set == null) return Container();

    return SizedBox(
      height: 217,
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index < set.exercises.length) {
            return _buildSetItem(
              set.exercises[index],
              set.exercises.indexOf(timetable.currentExercise) == index,
            );
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

  Widget _buildSetItem(Exercise exercise, bool active) => ListTile(
        tileColor: active
            ? Theme.of(context).primaryColor
            : Theme.of(context).focusColor,
        title: Text(exercise.name),
        subtitle: Text(
          S
              .of(context)
              .durationWithTime(Utils.formatSeconds(exercise.duration)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!timetable.isInitialized) {
      return Container();
    }
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_workout.title),
          scrolledUnderElevation: 1,
          elevation: 1,
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // left side of footer
              Expanded(
                child: ListTile(
                title: Text(S.of(context).exerciseOf(
                    timetable.currentSet.exercises
                            .indexOf(timetable.currentExercise) +
                        1 +
                        (timetable.currentReps *
                            timetable.currentSet.exercises.length),
                    timetable.currentSet.exercises.length *
                        timetable.currentSet.repetitions)),
                subtitle: Text(S.of(context).repOf(timetable.currentReps + 1,
                    timetable.currentSet.repetitions)),
              )),
              // right side of footer
              Expanded(
                  child: ListTile(
                title: Text(
                  S.of(context).setOf(
                      _workout.sets.indexOf(timetable.currentSet) + 1,
                      _workout.sets.length),
                  textAlign: TextAlign.end,
                ),
                subtitle: Text(
                  S.of(context).durationLeft(
                      Utils.formatSeconds(
                          _workout.duration - timetable.currentSecond + 10),
                      Utils.formatSeconds(_workout.duration + 10)),
                  textAlign: TextAlign.end,
                ),
              ))
            ],
          )),
          body: Column(
            children: [
              // top card with current exercise
              Card(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        timetable.currentSet.name ?? S.of(context).setIndex(_workout.sets.indexOf(timetable.currentSet) + 1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Utils.formatSeconds(timetable.remainingSeconds),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      LinearProgressIndicator(
                        value: timetable.remainingSeconds /
                            (timetable.currentSecond < 10
                                ? 10
                                : timetable.currentExercise.duration),
                        minHeight: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary),
                      ),
                      Text(
                        timetable.currentExercise.name,
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      timetable.nextExercise != null
                          ? Text(
                              S.of(context).nextExercise(
                                  timetable.nextExercise?.name ?? ''),
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            )
                          : Container(),
                    ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  // card with current set
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            S.of(context).currentSet,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildCurrentSetList(timetable.currentSet),
                      ],
                    ),
                  ),
                  // card with next set
                  timetable.nextSet != null
                      ? Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  S.of(context).nextSet,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: timetable.nextSet != null
                                    ? Text(
                                        S.of(context).countRepetitions(
                                              timetable.nextSet!.repetitions,
                                            ),
                                      )
                                    : null,
                              ),
                              _buildNextSetList(timetable.nextSet),
                            ],
                          ),
                        )
                      : const Column(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'FAB1',
              mini: true,
              onPressed: timetable.isActive ? timetable.skipBackward : null,
              child: const Icon(Icons.skip_previous),
            ),
            FloatingActionButton(
              heroTag: 'mainFAB',
              elevation: 8,
              child: Icon(
                timetable.isActive
                    ? Icons.pause
                    : timetable.workoutDone
                        ? Icons.replay
                        : Icons.play_arrow,
                size: 32,
              ),
              onPressed: () {
                if (timetable.isActive) {
                  timetable.timerStop();
                } else if (timetable.workoutDone) {
                  timetable.resetWorkout();
                } else {
                  timetable.timerStart();
                }
              },
            ),
            FloatingActionButton(
              heroTag: 'FAB2',
              mini: true,
              onPressed: timetable.isActive ? timetable.skipForward : null,
              child: const Icon(Icons.skip_next),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
      onWillPop: () async {
        // Just pop if the workout wasn't started yet or is already done
        if (timetable.canQuit) {
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
          ),
        );

        return value == true;
      },
    );
  }
}
