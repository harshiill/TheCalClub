import 'package:equatable/equatable.dart';

/// Clean domain entity for daily steps data
class DailyStepsData extends Equatable {
  final int totalSteps;
  final DateTime date;
  final DateTime lastUpdated;

  const DailyStepsData({
    required this.totalSteps,
    required this.date,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [totalSteps, date, lastUpdated];
}

/// Clean domain entity for workout/exercise data
class WorkoutData extends Equatable {
  final String id;
  final WorkoutType workoutType;
  final double activeCalories;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final int? steps;
  final double? distance; // in meters
  final double? averageHeartRate;
  final double? peakHeartRate;
  final double? averagePace; // in minutes per km

  const WorkoutData({
    required this.id,
    required this.workoutType,
    required this.activeCalories,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.steps,
    this.distance,
    this.averageHeartRate,
    this.peakHeartRate,
    this.averagePace,
  });

  @override
  List<Object?> get props => [
        id,
        workoutType,
        activeCalories,
        duration,
        startTime,
        endTime,
        steps,
        distance,
        averageHeartRate,
        peakHeartRate,
        averagePace,
      ];
}

/// Enum for different workout types
enum WorkoutType {
  running,
  walking,
  cycling,
  swimming,
  strengthTraining,
  yoga,
  hiking,
  other;

  String get displayName {
    switch (this) {
      case WorkoutType.running:
        return 'Running';
      case WorkoutType.walking:
        return 'Walking';
      case WorkoutType.cycling:
        return 'Cycling';
      case WorkoutType.swimming:
        return 'Swimming';
      case WorkoutType.strengthTraining:
        return 'Strength Training';
      case WorkoutType.yoga:
        return 'Yoga';
      case WorkoutType.hiking:
        return 'Hiking';
      case WorkoutType.other:
        return 'Exercise';
    }
  }

  String get icon {
    switch (this) {
      case WorkoutType.running:
        return '🏃';
      case WorkoutType.walking:
        return '🚶';
      case WorkoutType.cycling:
        return '🚴';
      case WorkoutType.swimming:
        return '🏊';
      case WorkoutType.strengthTraining:
        return '💪';
      case WorkoutType.yoga:
        return '🧘';
      case WorkoutType.hiking:
        return '🥾';
      case WorkoutType.other:
        return '⚡';
    }
  }
}