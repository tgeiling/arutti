require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create express app
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(helmet());
app.use(cors());
app.use(bodyParser.json());
app.use('/models', express.static(path.join(__dirname, 'models')));

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

// Configure Multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, 'models');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});
const upload = multer({ storage });

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

// Endpoint to retrieve all model setcards (public access)
app.get('/api/setcards', async (req, res) => {
  try {
    const setcards = await Setcard.find();
    res.json(setcards);
  } catch (error) {
    res.status(500).json({ message: 'Error retrieving setcards', error });
  }
});

// Endpoint to save a new model setcard with image uploads (requires valid JWT token)
app.post('/api/setcards', authenticateToken, upload.array('photos'), async (req, res) => {
  const { name, age, height, measurements } = req.body;
  
  // Collect paths of uploaded photos
  const photoPaths = req.files.map(file => `/models/${file.filename}`);

  const newSetcard = new Setcard({
    name,
    age: Number(age),
    height: Number(height),
    measurements: {
      chest: Number(measurements.chest),
      waist: Number(measurements.waist),
      hips: Number(measurements.hips),
    },
    photos: photoPaths,
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
