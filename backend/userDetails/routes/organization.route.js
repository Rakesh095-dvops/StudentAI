const express = require('express');
const router = express.Router();
const { getUsersWithDetails } = require('../controllers/organizationResume.controller');

// Define the route for fetching the users with their details presence flag
router.get('/:id', getUsersWithDetails);

module.exports = router;
