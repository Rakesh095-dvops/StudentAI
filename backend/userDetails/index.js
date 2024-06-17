// Import necessary modules
require('dotenv').config(); // Load environment variables from .env file
const express = require('express');
const app = express();

// Import routes
const userDetailsRoutes = require('./routes/userDetails.route');
const resumeRoutes = require('./routes/resume.route');


// Middleware
app.use(express.json()); // for parsing application/json

// Use routes
app.use('/api/userDetails', userDetailsRoutes);
app.use('/api/resume', resumeRoutes);


// Set the port number from the environment variable or default to 3000
const PORT = process.env.PORT;

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
