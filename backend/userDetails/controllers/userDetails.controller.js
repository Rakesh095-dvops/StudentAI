// Import the UserDetails model
const UserDetails = require('../models/userdetails.model');

// Add a new user's details
const addUserDetails = async (req, res) => {
    try {
        console.log('Insidee the addUserDetails')
        console.log('userId recev: ', req.user)
        const filter = { userId: req.user.id };  // Filter to find the document
        const update = { 
            ...req.body,
            userId: req.user.userId  // Ensure userId is included in the update or creation
        };        
        console.log('data: ', req.body)
        const options = { new: true, upsert: true, runValidators: true };  // Options to return the new document and create if not exists

        const userDetails = await UserDetails.findOneAndUpdate(filter, update, options);
        res.status(201).send({
            message: "Data Updated successfully",
            status: "success"
        });
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
        const user = await UserDetails.find({userId: req.params.id});
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
