import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'settings_page.dart';
import 'storage_helper.dart';
import 'utils.dart';
import 'workout.dart';
import 'workout_builder.dart';
import 'workout_runner.dart';

/// Main screen
class HomePage extends StatefulWidget {
  HomePage() : super();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _loadWorkouts();
    });
  }

  /// load all workouts from disk and populate list
  _loadWorkouts() async {
    getAllWorkouts().then((value) => setState(() {
          workouts = value;
          _saveSorting();
        }));
  }

  _saveSorting() {
    for (var workout in workouts.asMap().entries) {
      workout.value.position = workout.key;
      writeWorkout(workout.value);
    }
  }

  /// aks user if they want to delete a workout
  _showDeleteDialog(BuildContext context, Workout workout) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(S.of(context).cancel),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text(S.of(context).delete),
      onPressed: () {
        deleteWorkout(workout.title);
        _loadWorkouts();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    var alert = AlertDialog(
      title: Text(S.of(context).delete),
      content: Text(S.of(context).deleteConfirmation(workout.title)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (context) => alert,
    );
  }

  Widget _buildWorkoutList() => ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          setState(() {
            var workout = workouts.removeAt(oldIndex);
            workouts.insert(newIndex, workout);
          });
          _saveSorting();
        },
        children: workouts.map(_buildWorkoutItem).toList(),
      );

  Widget _buildWorkoutItem(Workout workout) => Card(
      key: Key(workout.id),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ReorderableDragStartListener(
                child: Icon(Icons.drag_handle), index: workout.position),
          ),
          Expanded(
            child: ListTile(
              title: Text(workout.title),
              subtitle: Text(S
                  .of(context)
                  .durationWithTime(Utils.formatSeconds(workout.duration))),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: S.of(context).editWorkout,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BuilderPage(workout: workout, newWorkout: false),
                ),
              ).then((value) => _loadWorkouts());
            },
          ),
          IconButton(
              icon: Icon(Icons.play_circle_fill),
              tooltip: S.of(context).startWorkout,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutPage(workout: workout),
                  ),
                ).then((value) => _loadWorkouts());
              }),
          IconButton(
              icon: Icon(Icons.delete),
              tooltip: S.of(context).deleteWorkout,
              onPressed: () {
                _showDeleteDialog(context, workout);
              }),
          IconButton(
              onPressed: () {
                exportWorkout(workout.title);
              },
              icon: Icon(Icons.save_alt))
        ],
      ));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).workouts),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsPage()))
                      .then((value) => _loadWorkouts());
                })
          ],
        ),
        body: _buildWorkoutList(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'mainFAB',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuilderPage(
                  workout: Workout(),
                  newWorkout: true,
                ),
              ),
            ).then((value) => _loadWorkouts());
          },
          tooltip: S.of(context).addWorkout,
          child: Icon(Icons.add),
        ),
      );
}
