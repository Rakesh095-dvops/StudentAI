// Import the mongoose module from the utils folder
const { mongoose } = require('../utils/conn');

// Define the schema for a user's educational qualification
const educationSchema = new mongoose.Schema({
    collegeName: String,
    degree: String,
    years: String,
    specialization: String
});

// Define the schema for a user's professional qualification
const professionalSchema = new mongoose.Schema({
    companyName: String,
    duration: {
        from: Date,
        to: Date
    },
    role: String,
    description: String
});

// Define the schema for a user's projects
const projectSchema = new mongoose.Schema({
    projectName: String,
    projectDescription: String,
    skillsUsed: [String],
    projectLink: String
});

// Create a schema for the UserDetails
const userDetailsSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    contactDetails: {
        phone: String,
        address: String
    },
    educationQualifications: [educationSchema],
    about: String,
    professionalQualifications: [professionalSchema],
    skills: [String],
    certifications: [String],
    specialAchievements: [String],
    projects: [projectSchema]
});

// Create a model from the schema
const UserDetails = mongoose.model('UserDetails', userDetailsSchema);

// Export the UserDetails model
module.exports = UserDetails;
