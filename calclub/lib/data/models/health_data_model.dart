import '../../domain/entities/health_data.dart';

/// Data model for daily steps (used for JSON serialization)
class DailyStepsModel {
  final int totalSteps;
  final DateTime date;
  final DateTime lastUpdated;

  DailyStepsModel({
    required this.totalSteps,
    required this.date,
    required this.lastUpdated,
  });

  /// Convert to domain entity
  DailyStepsData toEntity() {
    return DailyStepsData(
      totalSteps: totalSteps,
      date: date,
      lastUpdated: lastUpdated,
    );
  }

  /// Create from domain entity
  factory DailyStepsModel.fromEntity(DailyStepsData entity) {
    return DailyStepsModel(
      totalSteps: entity.totalSteps,
      date: entity.date,
      lastUpdated: entity.lastUpdated,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'date': date.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory DailyStepsModel.fromJson(Map<String, dynamic> json) {
    return DailyStepsModel(
      totalSteps: json['totalSteps'] as int,
      date: DateTime.parse(json['date'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

/// Data model for workout data (used for JSON serialization)
class WorkoutDataModel {
  final String id;
  final String workoutType;
  final double activeCalories;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime endTime;
  final int? steps;
  final double? distance;
  final double? averageHeartRate;
  final double? peakHeartRate;
  final double? averagePace;

  WorkoutDataModel({
    required this.id,
    required this.workoutType,
    required this.activeCalories,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    this.steps,
    this.distance,
    this.averageHeartRate,
    this.peakHeartRate,
    this.averagePace,
  });

  /// Convert to domain entity
  WorkoutData toEntity() {
    return WorkoutData(
      id: id,
      workoutType: _parseWorkoutType(workoutType),
      activeCalories: activeCalories,
      duration: Duration(minutes: durationMinutes),
      startTime: startTime,
      endTime: endTime,
      steps: steps,
      distance: distance,
      averageHeartRate: averageHeartRate,
      peakHeartRate: peakHeartRate,
      averagePace: averagePace,
    );
  }

  /// Create from domain entity
  factory WorkoutDataModel.fromEntity(WorkoutData entity) {
    return WorkoutDataModel(
      id: entity.id,
      workoutType: entity.workoutType.name,
      activeCalories: entity.activeCalories,
      durationMinutes: entity.duration.inMinutes,
      startTime: entity.startTime,
      endTime: entity.endTime,
      steps: entity.steps,
      distance: entity.distance,
      averageHeartRate: entity.averageHeartRate,
      peakHeartRate: entity.peakHeartRate,
      averagePace: entity.averagePace,
    );
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutType': workoutType,
      'activeCalories': activeCalories,
      'durationMinutes': durationMinutes,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'averageHeartRate': averageHeartRate,
      'peakHeartRate': peakHeartRate,
      'averagePace': averagePace,
    };
  }

  /// Create from JSON
  factory WorkoutDataModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDataModel(
      id: json['id'] as String,
      workoutType: json['workoutType'] as String,
      activeCalories: (json['activeCalories'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      steps: json['steps'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num?)?.toDouble(),
      peakHeartRate: (json['peakHeartRate'] as num?)?.toDouble(),
      averagePace: (json['averagePace'] as num?)?.toDouble(),
    );
  }

  /// Helper to parse workout type string to enum
  static WorkoutType _parseWorkoutType(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return WorkoutType.running;
      case 'walking':
        return WorkoutType.walking;
      case 'cycling':
        return WorkoutType.cycling;
      case 'swimming':
        return WorkoutType.swimming;
      case 'strengthtraining':
      case 'strength_training':
        return WorkoutType.strengthTraining;
      case 'yoga':
        return WorkoutType.yoga;
      case 'hiking':
        return WorkoutType.hiking;
      default:
        return WorkoutType.other;
    }
  }
}