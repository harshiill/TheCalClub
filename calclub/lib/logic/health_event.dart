import 'package:equatable/equatable.dart';

/// Base class for all health-related events
abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request health permissions
class RequestPermissionsEvent extends HealthEvent {
  const RequestPermissionsEvent();
}

/// Event to check if permissions are already granted
class CheckPermissionsEvent extends HealthEvent {
  const CheckPermissionsEvent();
}

/// Event to fetch all health data (steps + workouts)
class FetchHealthDataEvent extends HealthEvent {
  const FetchHealthDataEvent();
}

/// Event to refresh/reload health data
class RefreshHealthDataEvent extends HealthEvent {
  const RefreshHealthDataEvent();
}

/// Event to sync data to backend
class SyncToBackendEvent extends HealthEvent {
  const SyncToBackendEvent();
}

/// Event to initialize background sync
class InitializeBackgroundSyncEvent extends HealthEvent {
  const InitializeBackgroundSyncEvent();
}