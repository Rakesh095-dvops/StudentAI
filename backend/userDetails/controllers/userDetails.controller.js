// Import the UserDetails model
const UserDetails = require('../models/userdetails.model');

// Add a new user's details
const addUserDetails = async (req, res) => {
    try {
        const { email, ...otherUpdates } = req.body;
        const filter = { userId: req.user.userId };
        console.log('User Details Data: ', req.body)

        // Check if the user details already exist
        const existingUserDetails = await UserDetails.findOne(filter);

        let update = { $set: otherUpdates };
        let options = { new: true, runValidators: true };

        if (!existingUserDetails) {
            // If no existing details, prepare to set email and userId on insert
            update.$setOnInsert = { email: email, userId: req.user.userId };
            options.upsert = true;  // Enable upsert only if no document exists
        }

        const userDetails = await UserDetails.findOneAndUpdate(filter, update, options);
        res.status(201).send(userDetails);
    } catch (error) {
        console.error('Update Error:', error);
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
        console.log('User Data Fetched: ', user[0].professionalQualifications)
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
