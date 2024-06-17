// Import express
const express = require('express');
// Create a router object
const router = express.Router();

// Import the resume controller
const { createCV } = require('../controllers/resume.controller');

// Define the route for creating a CV
router.post('/', createCV);

// Export the router
module.exports = router;
