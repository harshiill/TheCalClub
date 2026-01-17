// ignore_for_file: unnecessary_cast

import 'dart:convert';

import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/health_data.dart';
import '../../domain/repositories/health_repository.dart';
import '../models/health_data_model.dart';

class HealthRepositoryImpl implements IHealthRepository {
  final Health _health = Health();

  static const String _lastSyncKey = 'last_sync_time';
  // Note: Replace with your computer's local IP address (e.g., 192.168.1.XX)
  static const String _backendUrl = 'http://192.168.2.61:3000';

  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_DELTA,
  ];

  @override
  Future<bool> requestPermissions() async {
    try {
      final permissions =
          _dataTypes.map((_) => HealthDataAccess.READ).toList();

      return await _health.requestAuthorization(
        _dataTypes,
        permissions: permissions,
      );
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_dataTypes) ?? false;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  @override
  Future<DailyStepsData?> fetchDailySteps() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );

      final totalSteps = healthData
          .where((e) => e.value is NumericHealthValue)
          .fold<int>(
            0,
            (sum, e) =>
                sum +
                (e.value as NumericHealthValue)
                    .numericValue
                    .toInt(),
          );

      return DailyStepsData(
        totalSteps: totalSteps,
        date: startOfDay,
        lastUpdated: now,
      );
    } catch (e) {
      print('Error fetching daily steps: $e');
      return null;
    }
  }

  @override
  Future<List<WorkoutData>> fetchRecentWorkouts({int days = 7}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: startDate,
        endTime: now,
      );

      final workouts = <WorkoutData>[];

      for (final data in healthData) {
        if (data.value is! WorkoutHealthValue) continue;

        final workout = data.value as WorkoutHealthValue;

        final calories =
            await _fetchWorkoutCalories(data.dateFrom, data.dateTo);
        final steps =
            await _fetchWorkoutSteps(data.dateFrom, data.dateTo);
        final heartRate =
            await _fetchHeartRateData(data.dateFrom, data.dateTo);

        final distance =
            workout.totalDistance?.toDouble();

        workouts.add(
          WorkoutData(
            id: data.dateFrom.millisecondsSinceEpoch.toString(),
            workoutType:
                _mapWorkoutType(workout.workoutActivityType),
            activeCalories: calories.toDouble(),
            duration: data.dateTo.difference(data.dateFrom),
            startTime: data.dateFrom,
            endTime: data.dateTo,
            steps: steps,
            distance: distance,
            averageHeartRate: heartRate['average'],
            peakHeartRate: heartRate['peak'],
            averagePace: _calculatePace(
              distance,
              data.dateTo.difference(data.dateFrom),
            ),
          ),
        );
      }

      workouts.sort((a, b) => b.startTime.compareTo(a.startTime));
      return workouts;
    } catch (e) {
      print('Error fetching workouts: $e');
      return [];
    }
  }

  Future<double> _fetchWorkoutCalories(
      DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );

      return data
          .where((e) => e.value is NumericHealthValue)
          .fold<double>(
            0,
            (sum, e) =>
                sum +
                (e.value as NumericHealthValue).numericValue,
          );
    } catch (_) {
      return 0;
    }
  }

  Future<int?> _fetchWorkoutSteps(
      DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      final total = data
          .where((e) => e.value is NumericHealthValue)
          .fold<int>(
            0,
            (sum, e) =>
                sum +
                (e.value as NumericHealthValue)
                    .numericValue
                    .toInt(),
          );

      return total > 0 ? total : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, double?>> _fetchHeartRateData(
      DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      final rates = data
          .where((e) => e.value is NumericHealthValue)
          .map((e) =>
              (e.value as NumericHealthValue).numericValue)
          .toList();

      if (rates.isEmpty) {
        return {'average': null, 'peak': null};
      }

      return {
        'average': (rates.reduce((a, b) => a + b) / rates.length) as double,
        'peak': rates.reduce((a, b) => a > b ? a : b) as double,
      };
    } catch (_) {
      return {'average': null, 'peak': null};
    }
  }

  double? _calculatePace(double? distanceMeters, Duration duration) {
    if (distanceMeters == null || distanceMeters == 0) return null;

    final km = distanceMeters / 1000;
    return duration.inMinutes / km;
  }

  WorkoutType _mapWorkoutType(
      HealthWorkoutActivityType type) {
    switch (type) {
      case HealthWorkoutActivityType.RUNNING:
        return WorkoutType.running;
      case HealthWorkoutActivityType.WALKING:
        return WorkoutType.walking;
      case HealthWorkoutActivityType.SWIMMING:
        return WorkoutType.swimming;
      case HealthWorkoutActivityType.YOGA:
        return WorkoutType.yoga;
      case HealthWorkoutActivityType.HIKING:
        return WorkoutType.hiking;
      default:
        return WorkoutType.other;
    }
  }

  @override
  Future<bool> syncToBackend({
    DailyStepsData? dailySteps,
    List<WorkoutData>? workouts,
  }) async {
    try {
      final payload = {
        'userId': 'TheCalClub_User',
        'timestamp': DateTime.now().toIso8601String(),
        if (dailySteps != null)
          'dailySteps':
              DailyStepsModel.fromEntity(dailySteps).toJson(),
        if (workouts != null && workouts.isNotEmpty)
          'workouts': workouts
              .map((w) =>
                  WorkoutDataModel.fromEntity(w).toJson())
              .toList(),
      };

      final response = await http.post(
        Uri.parse('$_backendUrl/api/health/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        await _updateLastSyncTime();
        return true;
      }

      return false;
    } catch (e) {
      print('Error syncing to backend: $e');
      return false;
    }
  }

  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_lastSyncKey);
      return value != null ? DateTime.parse(value) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setupBackgroundSync() async {
    print('Background sync setup initiated for The Cal Club');
  }
}
