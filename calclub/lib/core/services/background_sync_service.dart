import 'dart:io';
import 'package:workmanager/workmanager.dart';
import '../../data/repositories/health_repository_impl.dart';

/// Service to handle background synchronization of workout data
class BackgroundSyncService {
  static const String taskName = 'workout_sync_task';
  static const String uniqueName = 'workout_background_sync';

  /// Initialize background sync based on platform
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await _initializeAndroidBackgroundSync();
    } else if (Platform.isIOS) {
      await _initializeIosBackgroundSync();
    }
  }

  /// Setup Android background sync using WorkManager
  static Future<void> _initializeAndroidBackgroundSync() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to true for debugging
      );

      // Register periodic task to check for new workouts
      await Workmanager().registerPeriodicTask(
        uniqueName,
        taskName,
        frequency: const Duration(hours: 1), // Check every hour
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );

      print('Android background sync initialized');
    } catch (e) {
      print('Failed to initialize Android background sync: $e');
    }
  }

  /// Setup iOS background sync using HealthKit Background Delivery
  static Future<void> _initializeIosBackgroundSync() async {
    try {
      // Note: iOS background delivery is handled by the Health package
      // and configured through HealthKit's enableBackgroundDelivery
      // This is typically called when requesting permissions
      
      print('iOS background sync initialized');
      print('Note: iOS uses HealthKit Background Delivery API');
    } catch (e) {
      print('Failed to initialize iOS background sync: $e');
    }
  }

  /// Cancel all background tasks
  static Future<void> cancelAll() async {
    if (Platform.isAndroid) {
      await Workmanager().cancelAll();
    }
  }
}

/// Callback dispatcher for WorkManager (Android)
/// This function runs in a separate isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Background sync task started: $task');

      // Initialize repository
      final repository = HealthRepositoryImpl();

      // Check if permissions are granted
      final hasPermissions = await repository.hasPermissions();
      if (!hasPermissions) {
        print('Background sync skipped: No permissions');
        return Future.value(true);
      }

      // Fetch recent workouts (last 24 hours only for background sync)
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      final workouts = await repository.fetchRecentWorkouts(days: 1);

      if (workouts.isNotEmpty) {
        // Sync to backend
        final success = await repository.syncToBackend(workouts: workouts);
        
        if (success) {
          print('Background sync successful: ${workouts.length} workouts synced');
        } else {
          print('Background sync failed');
        }
      } else {
        print('No new workouts to sync');
      }

      return Future.value(true);
    } catch (e) {
      print('Background sync error: $e');
      return Future.value(false);
    }
  });
}