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


// Import the resume controller
const {  basicCreateCV, getBasicResumeById, getBasicAllResumes, uploadResumeByBusiness  } = require('../controllers/basicResume.controller');

// Define the route for creating a CV
router.post('/', basicCreateCV);
router.get('/:id', getBasicResumeById);
router.get('/', getBasicAllResumes);
router.post('/upload/:uid', upload.single('file'), uploadResumeByBusiness);

// Export the router
module.exports = router;
