// Import express
const express = require('express');
// Create a router object
const router = express.Router();

// Import the resume controller
const { createLinkedin, getLinkedinById, getAllLinkedin} = require('../controllers/linkedin.controller');

// Define the route for creating a CV
router.post('/', createLinkedin);
router.get('/', getLinkedinById);
router.get('/all', getAllLinkedin);

// Export the router
module.exports = router;
