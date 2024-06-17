// Import the UserDetails model
const UserDetails = require('../models/userdetails.model');

// Add a new user's details
const addUserDetails = async (req, res) => {
    try {
        const newUserDetails = new UserDetails(req.body);
        const savedUserDetails = await newUserDetails.save();
        res.status(201).send(savedUserDetails);
    } catch (error) {
        res.status(400).send(error);
    }
};

// Get all users' details
const getAllUserDetails = async (req, res) => {
    try {
        const users = await UserDetails.find();
        res.status(200).send(users);
    } catch (error) {
        res.status(500).send(error);
    }
};

// Get a single user's details by ID
const getUserDetailsById = async (req, res) => {
    try {
        const user = await UserDetails.findById(req.params.id);
        if (!user) {
            return res.status(404).send({ message: "User not found" });
        }
        res.status(200).send(user);
    } catch (error) {
        res.status(500).send(error);
    }
};

// Update a user's details by ID
const updateUserDetailsById = async (req, res) => {
    try {
        const updatedUser = await UserDetails.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
        if (!updatedUser) {
            return res.status(404).send({ message: "User not found" });
        }
        res.status(200).send(updatedUser);
    } catch (error) {
        res.status(400).send(error);
    }
};

// Delete a user's details by ID
const deleteUserDetailsById = async (req, res) => {
    try {
        const deletedUser = await UserDetails.findByIdAndDelete(req.params.id);
        if (!deletedUser) {
            return res.status(404).send({ message: "User not found" });
        }
        res.status(200).send({ message: "User details deleted successfully" });
    } catch (error) {
        res.status(500).send(error);
    }
};

// Export the controller functions
module.exports = {
    addUserDetails,
    getAllUserDetails,
    getUserDetailsById,
    updateUserDetailsById,
    deleteUserDetailsById
};
