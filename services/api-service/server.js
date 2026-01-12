require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://app:secret@localhost:5432/appdb'
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Auth middleware
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    // Verify token with auth service
    const response = await fetch(`${process.env.AUTH_SERVICE_URL || 'http://localhost:3001'}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token })
    });
    
    if (!response.ok) {
      return res.status(401).json({ error: 'Invalid token' });
    }
    
    const userData = await response.json();
    req.user = userData;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ error: 'Token verification failed' });
  }
};

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'api-service', timestamp: new Date().toISOString() });
});

// Get all users (protected)
app.get('/api/users', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT id, email, name, created_at FROM users ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get user profile (protected)
app.get('/api/profile', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT id, email, name, created_at FROM users WHERE id = $1', [req.user.userId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  }
});

// Update user profile (protected)
app.put('/api/profile', authenticateToken, async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const result = await pool.query(
      'UPDATE users SET name = $1 WHERE id = $2 RETURNING id, email, name, created_at',
      [name, req.user.userId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  }
});

// Get application stats
app.get('/api/stats', async (req, res) => {
  try {
    const userCount = await pool.query('SELECT COUNT(*) FROM users');
    res.json({
      totalUsers: parseInt(userCount.rows[0].count),
      timestamp: new Date().toISOString(),
      version: '1.0.0'
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Database error' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`API Service running on port ${PORT}`);
});