// Import necessary modules
require('dotenv').config(); // Load environment variables from .env file
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());


// Import routes
const userDetailsRoutes = require('./routes/userDetails.route');
const resumeRoutes = require('./routes/resume.route');


// Middleware
app.use(express.json()); // for parsing application/json
const verifyToken = require('./utils/jwt.middleware')

// Use routes
app.use('/api/userDetails', verifyToken, userDetailsRoutes);
app.use('/api/resume', verifyToken, resumeRoutes);


// Set the port number from the environment variable or default to 3000
const PORT = process.env.PORT;

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
