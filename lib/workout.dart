import 'dart:convert';

class Workout {
  Workout({
    this.title = 'Workout',
    List<Set>? sets,
  }) {
    this.sets = sets ?? [Set()];
  }

  String title;
  late List<Set> sets;

  int get duration {
    var duration = 0;

    sets.forEach((set) => {duration += set.duration});

    return duration;
  }

  /// remove sets without any exercises
  void cleanUp() {
    sets.removeWhere((set) => set.exercises.isEmpty);
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
    this.repetitions = 1,
    List<Exercise>? exercises,
  }) {
    this.exercises = exercises ?? [Exercise()];
  }

  int repetitions;
  late List<Exercise> exercises;

  int get duration {
    var duration = 0;

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
  Exercise({this.name = 'Exercise', this.duration = 30});

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

class Backup {
  List<Workout> workouts;

  Backup({required this.workouts});

  factory Backup.fromRawJson(String str) => Backup.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Backup.fromJson(Map<String, dynamic> json) => Backup(
        workouts: List<Workout>.from(
            json["workouts"].map((x) => Workout.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "workouts": List<dynamic>.from(workouts.map((x) => x.toJson())),
      };
}
