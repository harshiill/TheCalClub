require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');

const healthRoutes = require('./routes/health');

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/health_fitness_db';

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Routes
app.use('/api/health', healthRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'Health & Fitness API Server',
    version: '1.0.0',
    endpoints: {
      sync: 'POST /api/health/sync',
      steps: 'GET /api/health/steps/:userId',
      workouts: 'GET /api/health/workouts/:userId',
      stats: 'GET /api/health/stats/:userId'
    }
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: err.message
  });
});

// MongoDB Connection
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✓ Connected to MongoDB');
  console.log(`  Database: ${MONGODB_URI}`);
  
  // Start server after DB connection
  app.listen(PORT, () => {
    console.log(`✓ Server running on port ${PORT}`);
    console.log(`  Local: http://localhost:${PORT}`);
    console.log(`  Health check: http://localhost:${PORT}/health`);
  });
})
.catch((error) => {
  console.error('✗ MongoDB connection error:', error);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err);
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\nShutting down gracefully...');
  await mongoose.connection.close();
  console.log('MongoDB connection closed');
  process.exit(0);
});