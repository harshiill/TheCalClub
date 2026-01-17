const express = require('express');
const router = express.Router();
const { DailySteps, Workout } = require('../models/HealthData');

// POST /api/health/sync - Sync health data from mobile app
router.post('/sync', async (req, res) => {
  try {
    const { userId, dailySteps, workouts, timestamp } = req.body;

    // Validate request
    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'userId is required'
      });
    }

    const results = {
      dailySteps: null,
      workouts: [],
      timestamp: new Date()
    };

    // Save or update daily steps
    if (dailySteps) {
      const stepsData = await DailySteps.findOneAndUpdate(
        {
          userId: userId,
          date: new Date(dailySteps.date).setHours(0, 0, 0, 0)
        },
        {
          userId: userId,
          totalSteps: dailySteps.totalSteps,
          date: new Date(dailySteps.date),
          lastUpdated: new Date(dailySteps.lastUpdated)
        },
        {
          upsert: true,
          new: true,
          setDefaultsOnInsert: true
        }
      );
      results.dailySteps = stepsData;
    }

    // Save workouts
    if (workouts && Array.isArray(workouts) && workouts.length > 0) {
      for (const workout of workouts) {
        try {
          const workoutData = await Workout.findOneAndUpdate(
            {
              workoutId: workout.id
            },
            {
              userId: userId,
              workoutId: workout.id,
              workoutType: workout.workoutType,
              activeCalories: workout.activeCalories,
              durationMinutes: workout.durationMinutes,
              startTime: new Date(workout.startTime),
              endTime: new Date(workout.endTime),
              steps: workout.steps,
              distance: workout.distance,
              averageHeartRate: workout.averageHeartRate,
              peakHeartRate: workout.peakHeartRate,
              averagePace: workout.averagePace
            },
            {
              upsert: true,
              new: true,
              setDefaultsOnInsert: true
            }
          );
          results.workouts.push(workoutData);
        } catch (error) {
          console.error(`Error saving workout ${workout.id}:`, error);
          // Continue with other workouts even if one fails
        }
      }
    }

    res.status(200).json({
      success: true,
      message: 'Health data synced successfully',
      data: results
    });

  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to sync health data',
      error: error.message
    });
  }
});

// GET /api/health/steps/:userId - Get daily steps history
router.get('/steps/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { startDate, endDate, limit = 30 } = req.query;

    const query = { userId };

    // Add date range filter if provided
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    const steps = await DailySteps.find(query)
      .sort({ date: -1 })
      .limit(parseInt(limit));

    res.status(200).json({
      success: true,
      data: steps,
      count: steps.length
    });

  } catch (error) {
    console.error('Error fetching steps:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch steps data',
      error: error.message
    });
  }
});

// GET /api/health/workouts/:userId - Get workout history
router.get('/workouts/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { startDate, endDate, limit = 50, workoutType } = req.query;

    const query = { userId };

    // Add date range filter if provided
    if (startDate || endDate) {
      query.startTime = {};
      if (startDate) query.startTime.$gte = new Date(startDate);
      if (endDate) query.startTime.$lte = new Date(endDate);
    }

    // Filter by workout type if provided
    if (workoutType) {
      query.workoutType = workoutType;
    }

    const workouts = await Workout.find(query)
      .sort({ startTime: -1 })
      .limit(parseInt(limit));

    res.status(200).json({
      success: true,
      data: workouts,
      count: workouts.length
    });

  } catch (error) {
    console.error('Error fetching workouts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch workouts',
      error: error.message
    });
  }
});

// GET /api/health/stats/:userId - Get user statistics
router.get('/stats/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Get total workouts count
    const totalWorkouts = await Workout.countDocuments({ userId });

    // Get total calories burned
    const caloriesAgg = await Workout.aggregate([
      { $match: { userId } },
      { $group: { _id: null, total: { $sum: '$activeCalories' } } }
    ]);
    const totalCalories = caloriesAgg.length > 0 ? caloriesAgg[0].total : 0;

    // Get average steps per day (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const stepsAgg = await DailySteps.aggregate([
      { 
        $match: { 
          userId,
          date: { $gte: thirtyDaysAgo }
        } 
      },
      { $group: { _id: null, avgSteps: { $avg: '$totalSteps' } } }
    ]);
    const avgSteps = stepsAgg.length > 0 ? Math.round(stepsAgg[0].avgSteps) : 0;

    // Get most recent workout
    const recentWorkout = await Workout.findOne({ userId })
      .sort({ startTime: -1 });

    res.status(200).json({
      success: true,
      data: {
        totalWorkouts,
        totalCalories: Math.round(totalCalories),
        avgStepsLast30Days: avgSteps,
        lastWorkout: recentWorkout
      }
    });

  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch statistics',
      error: error.message
    });
  }
});

module.exports = router;