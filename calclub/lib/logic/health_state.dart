import 'package:equatable/equatable.dart';
import '../domain/entities/health_data.dart';

/// Base class for all health states
abstract class HealthState extends Equatable {
  const HealthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class HealthInitial extends HealthState {
  const HealthInitial();
}

/// State when loading health data
class HealthLoading extends HealthState {
  final String? message;

  const HealthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when permissions are not granted
class HealthPermissionDenied extends HealthState {
  const HealthPermissionDenied();
}

/// State when permissions are granted
class HealthPermissionGranted extends HealthState {
  const HealthPermissionGranted();
}

/// State when health data is successfully loaded
class HealthDataLoaded extends HealthState {
  final DailyStepsData? dailySteps;
  final List<WorkoutData> workouts;
  final DateTime? lastSyncTime;
  final bool isSyncing;

  const HealthDataLoaded({
    this.dailySteps,
    required this.workouts,
    this.lastSyncTime,
    this.isSyncing = false,
  });

  @override
  List<Object?> get props => [dailySteps, workouts, lastSyncTime, isSyncing];

  /// Create a copy with updated fields
  HealthDataLoaded copyWith({
    DailyStepsData? dailySteps,
    List<WorkoutData>? workouts,
    DateTime? lastSyncTime,
    bool? isSyncing,
  }) {
    return HealthDataLoaded(
      dailySteps: dailySteps ?? this.dailySteps,
      workouts: workouts ?? this.workouts,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

/// State when sync is successful
class HealthSyncSuccess extends HealthState {
  final DateTime syncTime;

  const HealthSyncSuccess(this.syncTime);

  @override
  List<Object?> get props => [syncTime];
}

/// State when sync fails
class HealthSyncFailure extends HealthState {
  final String message;

  const HealthSyncFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when an error occurs
class HealthError extends HealthState {
  final String message;

  const HealthError(this.message);

  @override
  List<Object?> get props => [message];
}