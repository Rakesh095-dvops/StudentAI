// Import necessary models and tools
const Resume = require('../models/resume.model');
const UserDetails = require('../models/userdetails.model');
const {generateCV} = require('../utils/chatGPT'); 

// Function to create a CV based on a JD and user details
const createCV = async (req, res) => {
    try {
        
        const { jobDescription, companyName, profileName, applicationLink } = req.body;
        console.log('Data received for generatingCV: ', req.body)
        let userId = req.user.userId
        console.log('UserData: ', userId)
        // Fetch user details
        const userDetails = await UserDetails.find({userId: userId});
        if (!userDetails) {
            return res.status(404).send({ message: "User not found" });
        }
        console.log('User Found: ', userDetails)

        
        const { parsedData, improvements } = await generateCV(userDetails, jobDescription);
        console.log('CV: ', parsedData)
        console.log('cv: ', parsedData.generatedCV)
        console.log('improvements: ', parsedData.improvements)
        const newResume = new Resume({
            userId,
            companyName,
            jobDescription,
            profileName,
            applicationLink,
            generatedCV: JSON.stringify(parsedData),
            coverletter: JSON.stringify(parsedData.coverletter),
            improvements: {
                technicalImprovements: JSON.stringify(parsedData.improvements.technicalImprovements),
                generalImprovements: JSON.stringify(parsedData.improvements.generalImprovements)
            }
        });
        await newResume.save();

        
        res.status(201).send(newResume);
    } catch (error) {
        res.status(500).send({ message: "Error generating CV", error });
    }
};


const getResumeById = async (req, res) => {
    try {
        const { id } = req.params;
        const resume = await Resume.findById(id);
        if (!resume) {
            return res.status(404).send({ message: "Resume not found" });
        }
        res.status(200).send(resume);
    } catch (error) {
        res.status(500).send({ message: "Error fetching resume", error });
    }
};


const getAllResumes = async (req, res) => {
    try {
        const resumes = await Resume.find();
        res.status(200).send(resumes);
    } catch (error) {
        res.status(500).send({ message: "Error fetching resumes", error });
    }
};


const getAllResumeCompanyNameAndId = async (req, res) => {
    try {
        console.log('All resume requested by userId: ', req.user.userId)
    const resumes = await Resume.find({userId: req.user.userId}).select('companyName');
        res.status(200).send(resumes);
    } catch (error) {
        res.status(500).send({ message: "Error fetching resumes", error });
    }
};

// Export the controller function
module.exports = {
    createCV,
    getResumeById,
    getAllResumes,
    getAllResumeCompanyNameAndId
};
