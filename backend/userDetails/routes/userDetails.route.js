// Import express
const express = require('express');
// Create a router object
const router = express.Router();

// Import the userDetails controller
const {
    addUserDetails,
    getAllUserDetails,
    getUserDetailsById,
    updateUserDetailsById,
    deleteUserDetailsById
} = require('../controllers/userDetails.controller');

// Define routes for user details
router.post('/', addUserDetails); // Create a new user detail
router.get('/', getAllUserDetails); // Get all user details
router.get('/:id', getUserDetailsById); // Get a specific user detail by ID
router.put('/:id', updateUserDetailsById); // Update a specific user detail by ID
router.delete('/:id', deleteUserDetailsById); // Delete a specific user detail by ID

// Export the router
module.exports = router;
