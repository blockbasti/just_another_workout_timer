import 'dart:convert';

class Workout {
  Workout({
    this.title,
    this.sets,
  });

  Workout.empty() {
    title = 'Workout';
    sets = [
      Set.empty(),
    ];
  }

  String title;
  List<Set> sets;

  int get duration {
    var duration = 0;

    sets.forEach((set) => {duration += set.duration});

    return duration;
  }

  /// remove sets without any exercises
  void cleanUp() {
    sets.removeWhere((set) => set.exercises.isEmpty);
  }

  /// move a set up or down the order
  void moveSet(int index, {bool moveUp}) {
    var sets = this.sets.toList();
    if (!moveUp && index + 1 < this.sets.length) {
      var a = sets[index];
      var b = sets[index + 1];
      sets[index + 1] = a;
      sets[index] = b;
    } else if (moveUp && index - 1 >= 0) {
      var a = sets[index];
      var b = sets[index - 1];
      sets[index - 1] = a;
      sets[index] = b;
    }
    this.sets = sets;
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

  Set.empty() {
    repetitions = 1;
    exercises = [];
  }

  int repetitions = 1;
  List<Exercise> exercises = [];

  int get duration {
    var duration = 0;

    exercises.forEach((exercise) => {duration += exercise.duration});

    return duration * repetitions;
  }

  /// move an exercise up or down the order
  void moveExercise(int index, {bool moveUp}) {
    var sets = exercises.toList();
    if (!moveUp && index + 1 < exercises.length) {
      var a = sets[index];
      var b = sets[index + 1];
      sets[index + 1] = a;
      sets[index] = b;
    } else if (moveUp && index - 1 >= 0) {
      var a = sets[index];
      var b = sets[index - 1];
      sets[index - 1] = a;
      sets[index] = b;
    }
    exercises = sets;
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
