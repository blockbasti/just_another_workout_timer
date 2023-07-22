// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utils/workout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['title', 'sets'],
  );
  return Workout(
    title: json['title'] as String? ?? 'Workout',
    sets: (json['sets'] as List<dynamic>?)
        ?.map((e) => Set.fromJson(e as Map<String, dynamic>))
        .toList(),
    version: json['version'] as int? ?? 1,
    position: json['position'] as int? ?? -1,
  );
}

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'title': instance.title,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'version': instance.version,
      'position': instance.position,
    };

Set _$SetFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['repetitions', 'exercises'],
  );
  return Set(
    id: json['id'] as String?,
    repetitions: json['repetitions'] as int? ?? 1,
    exercises: (json['exercises'] as List<dynamic>?)
        ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'repetitions': instance.repetitions,
      'id': instance.id,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'duration'],
  );
  return Exercise(
    id: json['id'] as String?,
    name: json['name'] as String? ?? 'Exercise',
    duration: json['duration'] as int? ?? 30,
  );
}

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'duration': instance.duration,
    };

Backup _$BackupFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['workouts'],
  );
  return Backup(
    workouts: (json['workouts'] as List<dynamic>)
        .map((e) => Workout.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$BackupToJson(Backup instance) => <String, dynamic>{
      'workouts': instance.workouts.map((e) => e.toJson()).toList(),
    };
