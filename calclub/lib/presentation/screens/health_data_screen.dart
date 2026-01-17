// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../logic/health_bloc.dart';
import '../../logic/health_event.dart';
import '../../logic/health_state.dart';
import '../../domain/entities/health_data.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  // Brand Color for The Cal Club
  static const Color brandColor = Color(0xFFFF5722); 

  @override
  void initState() {
    super.initState();
    // Check permissions when screen loads
    context.read<HealthBloc>().add(const CheckPermissionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'THE CAL CLUB',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () {
              context.read<HealthBloc>().add(const SyncToBackendEvent());
            },
            tooltip: 'Sync to Cloud',
          ),
        ],
      ),
      body: BlocConsumer<HealthBloc, HealthState>(
        listener: (context, state) {
          if (state is HealthSyncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Data synced to The Cal Club Cloud'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is HealthSyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✗ ${state.message}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is HealthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HealthInitial || state is HealthLoading) {
            return _buildLoadingView(state);
          } else if (state is HealthPermissionDenied) {
            return _buildPermissionDeniedView();
          } else if (state is HealthPermissionGranted) {
            // Auto-fetch data after permission granted
            Future.microtask(() {
              context.read<HealthBloc>().add(const FetchHealthDataEvent());
            });
            return _buildLoadingView(state);
          } else if (state is HealthDataLoaded) {
            return _buildDataView(state);
          } else if (state is HealthSyncSuccess) {
            // Show the data while displaying sync success
            return _buildDataView(HealthDataLoaded(
              dailySteps: null,
              workouts: const [],
              lastSyncTime: state.syncTime,
            ));
          } else if (state is HealthError) {
            return _buildErrorView(state.message);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingView(HealthState state) {
    String message = 'Loading Health Data...';
    if (state is HealthLoading && state.message != null) {
      message = state.message!;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: brandColor),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                size: 80,
                color: brandColor,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Access Required',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'To provide personalized fitness insights, The Cal Club needs access to your Health Connect data.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<HealthBloc>().add(const RequestPermissionsEvent());
                },
                icon: const Icon(Icons.lock_open_rounded),
                label: const Text('ENABLE HEALTH ACCESS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataView(HealthDataLoaded state) {
    return RefreshIndicator(
      color: brandColor,
      onRefresh: () async {
        context.read<HealthBloc>().add(const RefreshHealthDataEvent());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Daily Steps Card
          _buildDailyStepsCard(state.dailySteps, state.lastSyncTime),
          
          const SizedBox(height: 32),
          
          // Recent Workouts Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR SESSIONS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.black87,
                ),
              ),
              if (state.isSyncing)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: brandColor),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Workouts List
          if (state.workouts.isEmpty)
            _buildEmptyWorkoutsView()
          else
            ...state.workouts.map((workout) => _buildWorkoutCard(workout)),
        ],
      ),
    );
  }

  Widget _buildDailyStepsCard(DailyStepsData? dailySteps, DateTime? lastSyncTime) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [brandColor, Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: brandColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DAILY ACTIVITY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dailySteps != null 
                      ? NumberFormat('#,###').format(dailySteps.totalSteps)
                      : '0',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'STEPS',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done_rounded, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    lastSyncTime != null 
                      ? 'SYNCED ${_formatLastSyncTime(lastSyncTime).toUpperCase()}'
                      : 'NOT SYNCED YET',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutData workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      workout.workoutType.icon,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.workoutType.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMM dd • HH:mm').format(workout.startTime),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWorkoutStat(
                  icon: Icons.local_fire_department_rounded,
                  label: 'CALORIES',
                  value: '${workout.activeCalories.toStringAsFixed(0)}',
                  unit: 'kcal',
                ),
                _buildWorkoutStat(
                  icon: Icons.timer_rounded,
                  label: 'DURATION',
                  value: _formatDuration(workout.duration),
                  unit: '',
                ),
                if (workout.distance != null)
                  _buildWorkoutStat(
                    icon: Icons.straighten_rounded,
                    label: 'DISTANCE',
                    value: (workout.distance! / 1000).toStringAsFixed(2),
                    unit: 'km',
                  ),
              ],
            ),
            if (workout.steps != null || workout.averageHeartRate != null)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (workout.steps != null)
                        _buildWorkoutStat(
                          icon: Icons.directions_walk_rounded,
                          label: 'STEPS',
                          value: NumberFormat('#,###').format(workout.steps),
                          unit: '',
                        ),
                      if (workout.averageHeartRate != null)
                        _buildWorkoutStat(
                          icon: Icons.favorite_rounded,
                          label: 'AVG HR',
                          value: workout.averageHeartRate!.toStringAsFixed(0),
                          unit: 'bpm',
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutStat({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: brandColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyWorkoutsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 64,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NO RECENT SESSIONS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your training data will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            const Text(
              'SYNC ERROR',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.read<HealthBloc>().add(const CheckPermissionsEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('RETRY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatLastSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, HH:mm').format(time);
    }
  }
}
