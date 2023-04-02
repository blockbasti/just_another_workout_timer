import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part '../workout.g.dart';

@JsonSerializable(explicitToJson: true)
class Workout {
  static const fileVersion = 2;

  Workout({this.title = 'Workout', List<Set>? sets, this.version = fileVersion, this.position = -1}) {
    this.sets = sets ?? [Set()];
  }

  @JsonKey(required: true)
  String title;
  @JsonKey(required: true)
  late List<Set> sets;

  @JsonKey(defaultValue: 1)
  int version;

  @JsonKey(defaultValue: -1)
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

  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Set {
  Set({
    String? id,
    this.repetitions = 1,
    List<Exercise>? exercises,
  }) {
    this.id = id ?? const Uuid().v4();
    this.exercises = exercises ?? [Exercise()];
  }

  @JsonKey(required: true)
  int repetitions;

  @JsonKey()
  late String id;

  @JsonKey(required: true)
  late List<Exercise> exercises;

  int get duration {
    var duration = 0;

    exercises.forEach((exercise) => {duration += exercise.duration});

    return duration * repetitions;
  }

  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);
  Map<String, dynamic> toJson() => _$SetToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Exercise {
  Exercise({String? id, this.name = 'Exercise', this.duration = 30}) {
    this.id = id ?? const Uuid().v4();
  }

  @JsonKey(required: true)
  String name;

  @JsonKey()
  late String id;

  @JsonKey(required: true, defaultValue: 30)
  int duration;

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Backup {
  @JsonKey(required: true)
  List<Workout> workouts;

  Backup({required this.workouts});

  factory Backup.fromJson(Map<String, dynamic> json) => _$BackupFromJson(json);
  Map<String, dynamic> toJson() => _$BackupToJson(this);
}
