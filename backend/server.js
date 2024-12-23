const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const authRoutes = require('./routes/auth'); // Import routes

const app = express();

app.use(bodyParser.json());
app.use(cors());

// Use authentication routes
app.use('/api/auth', authRoutes);

app.listen(3000, () => console.log('Server running on http://localhost:3000'));
