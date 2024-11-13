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

app.use(express.json());
app.use(helmet());
app.use(cors());
app.use(bodyParser.json());

// MongoDB connection (using the same MongoDB cluster but different database and collection)
mongoose.connect(process.env.MONGO_URI, {
  dbName: 'Arutti' // Connect to the Arutti database
})
  .then(() => {
    console.log('MongoDB connected to Arutti database');
  })
  .catch(err => {
    console.log('MongoDB connection error:', err);
  });

// Define the Model Setcard Schema for the Models collection
const setcardSchema = new mongoose.Schema({
    name: String,
    age: Number,
    height: Number,
    measurements: {
        chest: Number,
        waist: Number,
        hips: Number
    },
    photos: [String] // Array of photo URLs
});

// Create the Setcard Model (collection name: Models)
const Setcard = mongoose.model('Setcard', setcardSchema, 'Models');

// Middleware to authenticate JWT token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ message: 'Access denied: No token provided' });

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid or expired token' });
    req.user = user; // Add user information to the request
    next();
  });
}

// Test endpoint to check server accessibility
app.get('/api/test', (req, res) => {
  console.log("Test endpoint hit!");
  res.status(200).json({ message: "Test endpoint reached successfully!" });
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
  console.log("Processing setcard save request");
  const { name, age, height, measurements, photos } = req.body;

  const newSetcard = new Setcard({
      name,
      age,
      height,
      measurements,
      photos
  });

  try {
      const savedSetcard = await newSetcard.save();
      res.status(201).json(savedSetcard);
  } catch (error) {
      res.status(500).json({ message: 'Error saving setcard', error });
  }
});

// Endpoint to generate a guest token (public access)
app.post('/guestnode', (req, res) => {
  try {
    const guestToken = jwt.sign({ guest: true }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ accessToken: guestToken });
  } catch (error) {
    console.error('Error generating guest token:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
