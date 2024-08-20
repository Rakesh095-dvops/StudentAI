// const BasicResume = require("../models/basicresume.model");
const UserDetails = require("../models/userdetails.model");
const BasicResumeReview = require("../models/businessCVreview.model")
const {cvReview} = require("../utils/chatGPT");

const reviewCV = async (req, res) => {
    try {        
        const { userId } = req.body;
        // console.log('Data received for generatingCV: ', req.body)
        // let userId = req.user.userId
        console.log('UserData: ', userId)
        // Fetch user details
        const userDetails = await UserDetails.find({userId: userId});
        if (!userDetails) {
            return res.status(404).send({ message: "User not found" });
        }
        console.log('User Found: ', userDetails)
        const { parsedData } = await cvReview(userDetails);
        console.log('[Controller] CV Reviewed: ', parsedData)
        // console.log('cv: ', parsedData.generatedCV)
        // console.log('improvements: ', parsedData.improvements)
        const newResume = new BasicResumeReview({
            userId,
            review: parsedData            
        });
        await newResume.save();        
        res.status(201).send(newResume);
    } catch (error) {
        res.status(500).send({ message: "Error generating CV", error });
    }
};

const getAllReviews = async (req, res) => {
    try {
        const reviews = await BasicResumeReview.find();
        res.status(200).send(reviews);
    } catch (error) {
        res.status(500).send({ message: "Error fetching reviews", error });
    }
};

const getReviewByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        console.log('userId: ', userId)
        const review = await BasicResumeReview.find({ userId: userId });

        if (!review) {
            return res.status(404).send({ message: "Review not found for this learner" });
        }

        res.status(200).json(review);
    } catch (error) {
        res.status(500).send({ message: "Error fetching review", error });
    }
};

module.exports = { reviewCV, getAllReviews, getReviewByUserId }