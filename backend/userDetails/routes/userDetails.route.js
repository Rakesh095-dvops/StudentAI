// Import express
const express = require('express');
const crypto = require('crypto');
const multer = require('multer');
const mime = require('mime');

// Create a router object
const router = express.Router();
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, './uploads/')
    },
    filename: function (req, file, cb) {
      crypto.pseudoRandomBytes(16, function (err, raw) {
        cb(null, raw.toString('hex') + Date.now() + '.' + mime.extension(file.mimetype));
      });
    }
  });
const upload = multer({ storage: storage });

// Import the userDetails controller
const {
    addUserDetails,
    getAllUserDetails,
    getUserDetailsById,
    updateUserDetailsById,
    deleteUserDetailsById,
    uploadResume
} = require('../controllers/userDetails.controller');

// Define routes for user details
router.post('/', addUserDetails); // Create a new user detail
router.get('/', getAllUserDetails); // Get all user details
router.get('/:id', getUserDetailsById); // Get a specific user detail by ID
router.put('/:id', updateUserDetailsById); // Update a specific user detail by ID
router.delete('/:id', deleteUserDetailsById); // Delete a specific user detail by ID
router.post('/upload', upload.single('file'), uploadResume)

// Export the router
module.exports = router;
