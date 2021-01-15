import 'dart:convert';

class Workout {
  Workout({
    this.title,
    this.sets,
  });

  Workout.empty() {
    title = 'Workout';
    sets = [
      Set(repetitions: 1, exercises: [Exercise.withName('Exercise')])
    ];
  }

  String title;
  List<Set> sets;

  int get duration {
    int duration = 0;

    sets.forEach((set) => {duration += set.duration});

    return duration;
  }

  factory Workout.fromRawJson(String str) => Workout.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        title: json["title"],
        sets: List<Set>.from(json["sets"].map((x) => Set.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "sets": List<dynamic>.from(sets.map((x) => x.toJson())),
      };
}

class Set {
  Set({
    this.repetitions,
    this.exercises,
  });

  Set.withReps(int repetitions) {
    this.repetitions = repetitions;
    this.exercises = [];
  }

  int repetitions = 1;
  List<Exercise> exercises = [];

  int get duration {
    int duration = 0;

    exercises.forEach((exercise) => {duration += exercise.duration});

    return duration * repetitions;
  }

  factory Set.fromRawJson(String str) => Set.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Set.fromJson(Map<String, dynamic> json) => Set(
        repetitions: json["repetitions"],
        exercises: List<Exercise>.from(
            json["exercises"].map((x) => Exercise.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "repetitions": repetitions,
        "exercises": List<dynamic>.from(exercises.map((x) => x.toJson())),
      };
}

class Exercise {
  Exercise({
    this.name,
    this.duration,
  });

  Exercise.withName(String name) {
    this.name = name;
    this.duration = 30;
  }

  String name;
  int duration;

  factory Exercise.fromRawJson(String str) =>
      Exercise.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        name: json["name"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": duration,
      };
}
