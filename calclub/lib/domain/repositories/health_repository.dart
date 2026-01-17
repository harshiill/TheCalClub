import '../entities/health_data.dart';

/// Abstract repository interface for health data operations
/// This defines the contract that platform-specific implementations must follow
abstract class IHealthRepository {
  /// Request necessary permissions for reading health data
  /// Returns true if permissions are granted
  Future<bool> requestPermissions();

  /// Check if permissions are already granted
  Future<bool> hasPermissions();

  /// Fetch daily steps data for today
  /// This should be called on app open (foreground sync)
  Future<DailyStepsData?> fetchDailySteps();

  /// Fetch recent workout data (last 7 days)
  /// Returns list of workout sessions
  Future<List<WorkoutData>> fetchRecentWorkouts({int days = 7});

  /// Sync health data to backend server
  /// [dailySteps] - today's step data
  /// [workouts] - list of workouts to sync
  /// Returns true if sync was successful
  Future<bool> syncToBackend({
    DailyStepsData? dailySteps,
    List<WorkoutData>? workouts,
  });

  /// Initialize background sync for workout data
  /// This sets up platform-specific background listeners
  Future<void> setupBackgroundSync();

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime();
}