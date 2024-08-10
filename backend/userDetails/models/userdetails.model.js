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
    location: String,
    duration: {
        from: String,
        to: String
    },
    role: String,
    description: String
});

// Define the schema for a user's projects
const projectSchema = new mongoose.Schema({
    projectName: String,
    projectDescription: String,
    skillsUsed: [{
        value: String
    }],
    projectLink: String
});

// Create a schema for the UserDetails
const userDetailsSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },  // Link to User model
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    contactDetails: {
        phone: String,
        address: String
    },
    currentJobTitle: {type: String},
    educationQualifications: [educationSchema],
    about: {type: String},
    professionalQualifications: [professionalSchema],
    skills: [{
        value: {type: String}
    }],
    certifications: [{
        certificationName: {type: String},
        certificationIssuer: {type: String}
    }],
    specialAchievements: [String],
    projects: [projectSchema]
});


// Create a model from the schema
const UserDetails = mongoose.model('UserDetails', userDetailsSchema);

// Export the UserDetails model
module.exports = UserDetails;
