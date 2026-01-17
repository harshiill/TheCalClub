const mongoose = require('mongoose');

// Schema for daily steps data
const DailyStepsSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  totalSteps: {
    type: Number,
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  lastUpdated: {
    type: Date,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Compound index for efficient queries
DailyStepsSchema.index({ userId: 1, date: 1 }, { unique: true });

// Schema for workout data
const WorkoutSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  workoutId: {
    type: String,
    required: true,
    unique: true
  },
  workoutType: {
    type: String,
    required: true
  },
  activeCalories: {
    type: Number,
    required: true
  },
  durationMinutes: {
    type: Number,
    required: true
  },
  startTime: {
    type: Date,
    required: true
  },
  endTime: {
    type: Date,
    required: true
  },
  steps: {
    type: Number,
    default: null
  },
  distance: {
    type: Number,
    default: null
  },
  averageHeartRate: {
    type: Number,
    default: null
  },
  peakHeartRate: {
    type: Number,
    default: null
  },
  averagePace: {
    type: Number,
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Index for efficient queries
WorkoutSchema.index({ userId: 1, startTime: -1 });

// Create models
const DailySteps = mongoose.model('DailySteps', DailyStepsSchema);
const Workout = mongoose.model('Workout', WorkoutSchema);

module.exports = {
  DailySteps,
  Workout
};