// Import the mongoose module from the utils folder
const { mongoose } = require('../utils/conn');

// Define the schema for the Resume
const resumeSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'UserDetails', // Assuming UserDetails is the model where user data is stored
        required: true
    },
    companyName: {
        type: String
    },
    jobDescription: {
        type: String,
        required: true
    },
    generatedCV: {
        type: Object,
        required: true
    },
    improvements: {
        type: String,
        required: true
    }
});

// Create a model from the schema
const Resume = mongoose.model('Resume', resumeSchema);

// Export the Resume model
module.exports = Resume;
