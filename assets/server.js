require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

// Create express app
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(helmet());
app.use(cors());
app.use(bodyParser.json());

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
  photos: [String],
});

const Setcard = mongoose.model('Setcard', setcardSchema, 'Models');

// User Schema and Model for Authentication
const UserSchema = new mongoose.Schema({
  username: { type: String, unique: true },
  password: String,
  winStreak: { type: Number, default: 0 },
  exp: { type: Number, default: 0 },
  completedLevels: { type: Number, default: 0 },
});

const User = mongoose.model('User', UserSchema);

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

// Test Endpoint
app.get('/api/test', (req, res) => {
  console.log("Test endpoint hit!");
  res.status(200).json({ message: "Test endpoint reached successfully!" });
});

// Register Endpoint
app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;

  try {
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({ username, password: hashedPassword });
    await user.save();

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

// Login Endpoint
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ id: user._id, username: user.username }, JWT_SECRET, { expiresIn: '1d' });
    res.json({ token });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

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

// Guest Token Generation Endpoint
app.post('/api/guestnode', (req, res) => {
  try {
    const guestToken = jwt.sign({ guest: true }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ accessToken: guestToken });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
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
  const { name, age, height, measurements, photos } = req.body;

  const newSetcard = new Setcard({
    name,
    age,
    height,
    measurements,
    photos,
  });

  try {
    const savedSetcard = await newSetcard.save();
    res.status(201).json(savedSetcard);
  } catch (error) {
    res.status(500).json({ message: 'Error saving setcard', error });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
