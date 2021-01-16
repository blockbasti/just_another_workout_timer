import 'package:flutter/material.dart';
import 'package:just_another_workout_timer/Workout.dart';
import 'package:just_another_workout_timer/WorkoutBuilder.dart';
import 'package:just_another_workout_timer/WorkoutRunner.dart';

import 'SettingsPage.dart';
import 'StorageHelper.dart';
import 'Utils.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  final String title = 'Just Another Workout Timer';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkouts();
    });
  }

  _loadWorkouts() async {
    var data = await StorageHelper.getAllWorkouts();
    setState(() {
      this.workouts = data;
    });
  }

  _showDeleteDialog(BuildContext context, Workout workout) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text('Delete'),
      onPressed: () {
        StorageHelper.deleteWorkout(workout.title);
        _loadWorkouts();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Delete'),
      content: Text('Would you like to delete the workout "${workout.title}"?'),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index < workouts.length) {
          return _buildWorkoutItem(workouts[index]);
        } else
          return null;
      },
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    return Card(
        child: Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(workout.title),
            subtitle:
                Text('Duration: ${Utils.formatSeconds(workout.duration)} '),
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          tooltip: 'Edit workout',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuilderPage(workout: workout),
              ),
            ).then((value) => _loadWorkouts());
          },
        ),
        IconButton(
            icon: Icon(Icons.play_circle_fill),
            tooltip: 'Start workout',
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
            tooltip: 'Delete workout',
            onPressed: () {
              _showDeleteDialog(context, workout);
            })
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              })
        ],
      ),
      body: _buildWorkoutList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuilderPage(workout: Workout.empty()),
            ),
          ).then((value) => _loadWorkouts());
        },
        tooltip: 'Add workout',
        child: Icon(Icons.add),
      ),
    );
  }
}
