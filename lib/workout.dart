import 'package:dart_json_mapper/dart_json_mapper.dart'
    show Json, JsonProperty, jsonSerializable;
import 'package:uuid/uuid.dart';

@jsonSerializable
class Workout {
  static const fileVersion = 3;

  Workout(
      {String? id,
      this.title = 'Workout',
      List<Set>? sets,
      this.version = fileVersion,
      this.position = -1}) {
    this.id = id ?? Uuid().v4();
    this.sets = sets ?? [Set()];
  }
  @JsonProperty()
  late String id;
  @JsonProperty(required: true)
  String title;

  @JsonProperty(required: true)
  late List<Set> sets;

  @JsonProperty(defaultValue: 1)
  int version;

  @JsonProperty(defaultValue: -1)
  int position;

  int get duration {
    var duration = 0;

    sets.forEach((set) => {duration += set.duration});

    return duration;
  }

  /// remove sets without any exercises
  void cleanUp() {
    sets.removeWhere((set) => set.exercises.isEmpty);
  }
}

@jsonSerializable
class Set {
  Set({
    String? id,
    this.repetitions = 1,
    List<Exercise>? exercises,
  }) {
    this.id = id ?? Uuid().v4();
    this.exercises = exercises ?? [];
  }

  @JsonProperty(required: true)
  int repetitions;

  @JsonProperty()
  late String id;

  @JsonProperty(required: true)
  late List<Exercise> exercises;

  int get duration {
    var duration = 0;

    exercises.forEach((exercise) => {duration += exercise.duration});

    return duration * repetitions;
  }
}

@jsonSerializable
enum ExerciseType { counted, timed }

@jsonSerializable
@Json(discriminatorProperty: 'type')
abstract class Exercise {
  Exercise(
      {String? id,
      required this.type,
      this.name = 'Exercise',
      this.duration = 30}) {
    this.id = id ?? Uuid().v4();
  }

  @JsonProperty(required: true)
  String name;

  @JsonProperty()
  late String id;

  @JsonProperty(required: true, defaultValue: 30)
  int duration;

  final ExerciseType type;
}

@jsonSerializable
@Json(discriminatorValue: ExerciseType.timed)
class TimedExercise extends Exercise {
  TimedExercise({String? id, name = 'Exercise', duration = 30})
      : super(id: id, type: ExerciseType.timed, name: name, duration: duration);
}

@jsonSerializable
@Json(discriminatorValue: ExerciseType.counted)
class CountedExercise extends Exercise {
  CountedExercise({String? id, name = 'Exercise', this.count = 30})
      : super(id: id, type: ExerciseType.counted, name: name, duration: 0);

  @JsonProperty(required: true, defaultValue: 30)
  int count;

  int get duration => count * 2;
}

@jsonSerializable
class Backup {
  @JsonProperty(required: true)
  List<Workout> workouts;

  Backup({required this.workouts});
}
