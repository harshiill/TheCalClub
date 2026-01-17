import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/repositories/health_repository.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final IHealthRepository repository;

  HealthBloc({required this.repository}) : super(const HealthInitial()) {
    on<CheckPermissionsEvent>(_onCheckPermissions);
    on<RequestPermissionsEvent>(_onRequestPermissions);
    on<FetchHealthDataEvent>(_onFetchHealthData);
    on<RefreshHealthDataEvent>(_onRefreshHealthData);
    on<SyncToBackendEvent>(_onSyncToBackend);
    on<InitializeBackgroundSyncEvent>(_onInitializeBackgroundSync);
  }

  Future<void> _onCheckPermissions(
    CheckPermissionsEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      final hasPermissions = await repository.hasPermissions();
      
      if (hasPermissions) {
        emit(const HealthPermissionGranted());
      } else {
        emit(const HealthPermissionDenied());
      }
    } catch (e) {
      emit(HealthError('Failed to check permissions: $e'));
    }
  }

  Future<void> _onRequestPermissions(
    RequestPermissionsEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      emit(const HealthLoading(message: 'Requesting permissions...'));
      
      final granted = await repository.requestPermissions();
      
      if (granted) {
        emit(const HealthPermissionGranted());
        // Automatically fetch data after permissions are granted
        add(const FetchHealthDataEvent());
      } else {
        emit(const HealthPermissionDenied());
      }
    } catch (e) {
      emit(HealthError('Failed to request permissions: $e'));
    }
  }

  Future<void> _onFetchHealthData(
    FetchHealthDataEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      emit(const HealthLoading(message: 'Loading health data...'));

      // Fetch daily steps
      final dailySteps = await repository.fetchDailySteps();

      // Fetch recent workouts (last 7 days)
      final workouts = await repository.fetchRecentWorkouts(days: 7);

      // Get last sync time
      final lastSyncTime = await repository.getLastSyncTime();

      emit(HealthDataLoaded(
        dailySteps: dailySteps,
        workouts: workouts,
        lastSyncTime: lastSyncTime,
      ));
    } catch (e) {
      emit(HealthError('Failed to fetch health data: $e'));
    }
  }

  Future<void> _onRefreshHealthData(
    RefreshHealthDataEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      // Keep the current state but show loading indicator
      if (state is HealthDataLoaded) {
        final currentState = state as HealthDataLoaded;
        emit(currentState.copyWith(isSyncing: true));
      } else {
        emit(const HealthLoading(message: 'Refreshing...'));
      }

      // Fetch fresh data
      final dailySteps = await repository.fetchDailySteps();
      final workouts = await repository.fetchRecentWorkouts(days: 7);
      final lastSyncTime = await repository.getLastSyncTime();

      emit(HealthDataLoaded(
        dailySteps: dailySteps,
        workouts: workouts,
        lastSyncTime: lastSyncTime,
        isSyncing: false,
      ));
    } catch (e) {
      emit(HealthError('Failed to refresh health data: $e'));
    }
  }

  Future<void> _onSyncToBackend(
    SyncToBackendEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      if (state is! HealthDataLoaded) {
        emit(const HealthError('No data to sync'));
        return;
      }

      final currentState = state as HealthDataLoaded;
      
      // Show syncing indicator
      emit(currentState.copyWith(isSyncing: true));

      // Sync to backend
      final success = await repository.syncToBackend(
        dailySteps: currentState.dailySteps,
        workouts: currentState.workouts,
      );

      if (success) {
        final syncTime = DateTime.now();
        
        // Update state with new sync time
        emit(currentState.copyWith(
          lastSyncTime: syncTime,
          isSyncing: false,
        ));
        
        // Emit success state briefly
        emit(HealthSyncSuccess(syncTime));
        
        // Return to data loaded state
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState.copyWith(
          lastSyncTime: syncTime,
          isSyncing: false,
        ));
      } else {
        emit(const HealthSyncFailure('Failed to sync data to backend'));
        
        // Return to previous state after showing error
        await Future.delayed(const Duration(seconds: 3));
        emit(currentState.copyWith(isSyncing: false));
      }
    } catch (e) {
      emit(HealthError('Sync error: $e'));
    }
  }

  Future<void> _onInitializeBackgroundSync(
    InitializeBackgroundSyncEvent event,
    Emitter<HealthState> emit,
  ) async {
    try {
      await repository.setupBackgroundSync();
      // Background sync is now active
    } catch (e) {
      print('Failed to initialize background sync: $e');
    }
  }
}