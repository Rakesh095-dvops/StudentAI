// Import necessary modules
require('dotenv').config(); // Load environment variables from .env file
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.urlencoded({ extended: true }));


// Import routes
const userDetailsRoutes = require('./routes/userDetails.route');
const resumeRoutes = require('./routes/resume.route');
const basicResumeRoutes = require('./routes/basicresume.route');
const linkedinRoutes = require('./routes/linkedin.route')
const organizationRoutes = require('./routes/organization.route')

// Middleware
app.use(express.json()); // for parsing application/json
const verifyToken = require('./utils/jwt.middleware')

// Use routes
app.use('/api/userDetails', verifyToken, userDetailsRoutes);
app.use('/api/resume', verifyToken, resumeRoutes);
// app.use('/api/basicresume', verifyToken, basicResumeRoutes);
app.use('/api/basicresume', basicResumeRoutes);
app.use('/api/linkedin', verifyToken, linkedinRoutes);
app.use('/api/organization', organizationRoutes);
app.use('/api/org/userDetails', userDetailsRoutes);


// Set the port number from the environment variable or default to 3000
const PORT = process.env.PORT;

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
