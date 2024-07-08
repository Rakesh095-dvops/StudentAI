// Import express
const express = require('express');
// Create a router object
const router = express.Router();

// Import the resume controller
const { createCV, getResumeById, getAllResumes,getAllResumeCompanyNameAndId  } = require('../controllers/resume.controller');

// Define the route for creating a CV
router.post('/', createCV);
router.get('/:id', getResumeById);
router.get('/', getAllResumes);
router.get('/company/name',getAllResumeCompanyNameAndId)

// Export the router
module.exports = router;
