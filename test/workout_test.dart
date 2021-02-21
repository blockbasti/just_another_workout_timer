import 'package:flutter_test/flutter_test.dart';
import 'package:just_another_workout_timer/workout.dart';

// ignore_for_file: avoid_catches_without_on_clauses

void main() {
  group('Exercise', () {
    test('WHEN creating an exercise with name THEN values are correct', () {
      var exercise = Exercise(name: 'Exercise', duration: 30);

      expect(exercise.name, 'Exercise');
      expect(exercise.duration, 30);
    });

    test('GIVEN an exercise WHEN converting to JSON THEN output is valid', () {
      var exercise = Exercise(name: 'Exercise', duration: 30);

      var json = exercise.toRawJson();

      expect(json, '{"name":"Exercise","duration":30}');
    });

    test(
        'GIVEN a valid JSON string WHEN parsing to an exercise THEN exercise is correct',
        () {
      var json = '{"name":"Exercise","duration":30}';

      var exercise = Exercise.fromRawJson(json);

      expect(exercise.name, 'Exercise');
      expect(exercise.duration, 30);
    });

    test(
        'GIVEN an invalid JSON string WHEN parsing to an exercise THEN error is thrown',
        () {
      var json = '{"duration":"30"}';

      try {
        Exercise.fromRawJson(json);
      } catch (e) {
        expect(e is Error, true);
      }
    });
  });

  group('Set', () {
    test('WHEN creating an empty set THEN values are correct', () {
      var set = Set.empty();

      expect(set.repetitions, 1);
      expect(set.exercises.length, 0);
    });

    test(
        'GIVEN a set with exercises WHEN calculating duration THEN duration is correct',
        () {
      var setDefault = Set.empty();
      var setEmpty = Set(repetitions: 1, exercises: []);
      var setComplex = Set(repetitions: 3, exercises: [
        Exercise(name: 'Exercise', duration: 30),
        Exercise(name: 'Exercise', duration: 30)
      ]);

      expect(setDefault.duration, 0);
      expect(setEmpty.duration, 0);
      expect(setComplex.duration, 180);
    });

    test('GIVEN a set WHEN converting to JSON THEN output is valid', () {
      var set = Set.empty();
      set.exercises.add(Exercise(name: 'Exercise', duration: 30));

      var json = set.toRawJson();

      expect(json,
          '{"repetitions":1,"exercises":[{"name":"Exercise","duration":30}]}');
    });

    test('GIVEN a valid JSON string WHEN parsing to a set THEN set is correct',
        () {
      var json =
          '{"repetitions":1,"exercises":[{"name":"Exercise","duration":30}]}';

      var set = Set.fromRawJson(json);

      expect(set.repetitions, 1);
      expect(set.exercises.length, 1);
    });

    test(
        'GIVEN an invalid JSON string WHEN parsing to a set THEN error is thrown',
        () {
      var json = '{"repetitions":"1"}';

      try {
        Set.fromRawJson(json);
      } catch (e) {
        expect(e is Error, true);
      }
    });
  });

  group('Workout', () {
    test(
        'WHEN creating an empty workout THEN workout contains a single set with one exercise',
        () {
      var workout = Workout.empty();

      expect(workout.title, 'Workout');
      expect(workout.sets.length, 1);
      expect(workout.sets.first.exercises.length, 0);
    });

    test(
        'GIVEN a workout WHEN calculating the duration THEN duration is correct',
        () {
      var workoutDefault = Workout.empty();
      var workoutEmpty = Workout(title: 'Workout', sets: []);

      var set = Set.empty();
      set.exercises.add(Exercise(name: 'Exercise', duration: 30));

      var workoutComplex = Workout(title: 'Workout', sets: [set, set]);

      expect(workoutDefault.duration, 0);
      expect(workoutEmpty.duration, 0);
      expect(workoutComplex.duration, 60);
    });

    test('GIVEN a workout WHEN converting to JSON THEN output is valid', () {
      var workout = Workout.empty();
      workout.sets.first.exercises
          .add(Exercise(name: 'Exercise', duration: 30));

      var json = workout.toRawJson();

      expect(json,
          '{"title":"Workout","sets":[{"repetitions":1,"exercises":[{"name":"Exercise","duration":30}]}]}');
    });

    test(
        'GIVEN an invalid JSON string WHEN parsing to a workout THEN error is thrown',
        () {
      var json = '{"repetitions":"1"}';

      try {
        Workout.fromRawJson(json);
      } catch (e) {
        expect(e is Error, true);
      }
    });
  });
}
