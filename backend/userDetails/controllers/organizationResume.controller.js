const {User} = require('../models/user.model');
const UserDetails = require('../models/userdetails.model');
const mongoose = require('mongoose');

const getUsersWithDetails = async (req, res) => {
  try {
    const organizationId = req.params.id;
    // console.log('organization Requesting: ',organizationId )
    // Fetch all users that belong to the specified organization
    const users = await User.find({ organization: organizationId });
    console.log('users: ', users)

    if (users.length === 0) {
      return res.status(404).json({ message: 'No users found for this organization.' });
    }

    // Create a new array with the necessary fields and the isUserDetailsPresent flag
    const userList = await Promise.all(users.map(async user => {
      const userDetails = await UserDetails.findOne({ userId: user._id });

      return {
        _id: user._id,
        name: user.name,
        email: user.email,
        phoneNo: user.phoneNo,
        organization: user.organization,
        userType: user.userType,
        accountStatus: user.accountStatus,
        createdAt: user.createdAt,
        isUserDetailsPresent: userDetails ? 'yes' : 'no'
      };
    }));

    // Send the response with the list of users
    res.status(200).json(userList);
  } catch (error) {
    res.status(500).json({ message: 'An error occurred while fetching users.', error });
  }
};

module.exports = {
  getUsersWithDetails
};
