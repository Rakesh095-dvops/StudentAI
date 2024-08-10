const Linkedin = require('../models/linkedin.model')
const UserDetails = require('../models/userdetails.model');
const {generateLinkedin} = require("../utils/chatGPT");

const createLinkedin = async (req, res) => {
    try {
        let userId = req.user.userId;
        console.log('UserData: ', userId);

        // Fetch user details
        const userDetails = await UserDetails.findOne({ userId: userId });
        if (!userDetails) {
            return res.status(404).send({ message: "User not found" });
        }
        console.log('User Found: ', userDetails);

        // Generate LinkedIn profile data
        const { parsedData } = await generateLinkedin(userDetails);
        console.log('Li: ', parsedData);

        // Check if LinkedIn profile already exists for the user
        let linkedinProfile = await Linkedin.findOne({ userId: userId });

        if (linkedinProfile) {
            // Update existing LinkedIn profile
            linkedinProfile.linkedinProfile = JSON.stringify(parsedData);
            await linkedinProfile.save();
            res.status(200).send({ message: "LinkedIn profile updated", linkedinProfile });
        } else {
            // Create new LinkedIn profile
            linkedinProfile = new Linkedin({
                userId,
                linkedinProfile: JSON.stringify(parsedData)
            });
            await linkedinProfile.save();
            res.status(201).send({ message: "LinkedIn profile created", linkedinProfile });
        }
    } catch (error) {
        res.status(500).send({ message: "Error generating LinkedIn profile", error });
    }
};




const getLinkedinById = async (req, res) => {
    try {
        // const { id } = req.params;
        let  id  = req.user.userId;
        console.log(id)
        const linkedin = await Linkedin.find({userId: id});
        console.log('linkedin: ', linkedin)
        if (!linkedin) {
            return res.status(404).send({ message: "linkedin not found" });
        }
        res.status(200).send(linkedin[0].linkedinProfile);
    } catch (error) {
        res.status(500).send({ message: "Error fetching linkedin", error });
    }
};


const getAllLinkedin = async (req, res) => {
    try {
        const linkedin = await Linkedin.find();
        res.status(200).send(linkedin);
    } catch (error) {
        res.status(500).send({ message: "Error fetching linkedin", error });
    }
};

module.exports = {
    createLinkedin,
    getLinkedinById,
    getAllLinkedin
}