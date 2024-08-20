const express = require('express');
const router = express.Router();
const { getUsersWithDetails } = require('../controllers/organizationResume.controller');
const { reviewCV, getAllReviews, getReviewByUserId } = require('../controllers/basicCVreview.controller')
// Define the route for fetching the users with their details presence flag
router.get('/:id', getUsersWithDetails);
router.post('/review', reviewCV)
router.get('/', getAllReviews)
router.get('/review/:userId', getReviewByUserId)


module.exports = router;
