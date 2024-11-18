require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');

// Create express app
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json({ limit: '10mb' })); // Allow larger payloads for Base64 images
app.use(helmet());
app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));

// MongoDB connection
mongoose.connect(process.env.MONGO_URI, {
  dbName: 'Arutti',
})
  .then(() => console.log('MongoDB connected to Arutti database'))
  .catch(err => console.log('MongoDB connection error:', err));

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'arutti_secret';

// Define Model Setcard Schema and Model
const setcardSchema = new mongoose.Schema({
  name: String,
  age: Number,
  height: Number,
  measurements: {
    chest: Number,
    waist: Number,
    hips: Number,
  },
  photos: [String], // Store Base64 encoded images directly
});

const Setcard = mongoose.model('Setcard', setcardSchema, 'Models');

// Middleware to authenticate JWT token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ message: 'Access denied: No token provided' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid or expired token' });
    req.user = user;
    next();
  });
}

// Validate Token Endpoint
app.post('/api/validateToken', (req, res) => {
  const token = req.body.token;
  if (!token) return res.status(400).json({ message: 'Token required' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    res.json({ isValid: true, decoded });
  } catch (err) {
    res.status(401).json({ isValid: false, message: 'Invalid or expired token' });
  }
});

// Endpoint to retrieve all model setcards (public access)
app.get('/api/setcards', async (req, res) => {
  try {
    const setcards = await Setcard.find();
    res.json(setcards);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving setcards', error });
  }
});

// Endpoint to save a new model setcard (requires valid JWT token)
app.post('/api/setcards', authenticateToken, async (req, res) => {
  const { name, age, height, measurements = {}, photos = [] } = req.body;

  // Safely handle measurements or set defaults
  const measurementsObj = {
    chest: Number(measurements.chest || 0),
    waist: Number(measurements.waist || 0),
    hips: Number(measurements.hips || 0),
  };

  // Save Base64 images directly in the photos array
  const newSetcard = new Setcard({
    name,
    age: Number(age) || 0,
    height: Number(height) || 0,
    measurements: measurementsObj,
    photos, // Store Base64 encoded images
  });

  try {
    const savedSetcard = await newSetcard.save();
    res.status(201).json(savedSetcard);
  } catch (error) {
    console.error('Error saving setcard:', error);
    res.status(500).json({ message: 'Error saving setcard', error });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
