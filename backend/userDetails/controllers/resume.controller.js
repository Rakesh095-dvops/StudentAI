// Import necessary models and tools
const Resume = require('../models/resume.model');
const UserDetails = require('../models/userdetails.model');
const generateCV = require('../utils/chatGPT'); // Assuming a utility to handle ChatGPT API requests

// Function to create a CV based on a JD and user details
const createCV = async (req, res) => {
    try {
        
        const { jobDescription, companyName } = req.body;
        console.log('Data received for generatingCV: ', req.body)
        let userId = req.user.userId
        console.log('UserData: ', userId)
        // Fetch user details
        const userDetails = await UserDetails.find({userId: userId});
        if (!userDetails) {
            return res.status(404).send({ message: "User not found" });
        }
        console.log('User Found: ', userDetails)

        // Generate CV using ChatGPT API (This is a placeholder for the actual API call)
        const { parsedData, improvements } = await generateCV(userDetails, jobDescription);
        console.log('CV: ', parsedData)
        console.log('cv: ', parsedData.generatedCV)
        console.log('improvements: ', parsedData.suggestedImprovements)
        // improvements = JSON.stringify(parsedData.suggestedImprovements)

        // Save the generated CV and improvements in the database
        const newResume = new Resume({
            userId,
            companyName,
            jobDescription,
            generatedCV: JSON.stringify(parsedData.generatedCV),
            improvements: JSON.stringify(parsedData.suggestedImprovements)
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
