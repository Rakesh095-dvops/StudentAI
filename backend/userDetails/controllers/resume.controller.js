// Import necessary models and tools
const Resume = require('../models/resume.model');
const UserDetails = require('../models/userdetails.model');
const generateCV = require('../utils/chatGPT'); // Assuming a utility to handle ChatGPT API requests

// Function to create a CV based on a JD and user details
const createCV = async (req, res) => {
    try {
        const { userId, jobDescription } = req.body;
        console.log('UserData: ', userId, jobDescription)
        
        // Fetch user details
        const userDetails = await UserDetails.findById(userId);
        if (!userDetails) {
            return res.status(404).send({ message: "User not found" });
        }
        console.log('User Found: ', userDetails)

        // Generate CV using ChatGPT API (This is a placeholder for the actual API call)
        const { cv, improvements } = await generateCV(userDetails, jobDescription);

        // Save the generated CV and improvements in the database
        const newResume = new Resume({
            userId,
            jobDescription,
            generatedCV: cv,
            improvements
        });
        await newResume.save();

        // Send the generated CV and improvements
        res.status(201).send(newResume);
    } catch (error) {
        res.status(500).send({ message: "Error generating CV", error });
    }
};

// Export the controller function
module.exports = {
    createCV
};
