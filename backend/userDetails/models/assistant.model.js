// Import the mongoose module from the utils folder
const { mongoose } = require('../utils/conn');

// Define the schema for the Linkedin
const assistantSchema = new mongoose.Schema({
    assistantId: {
        type: String,
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now(),
  },
});

// Create a model from the schema
const Assistant = mongoose.model('Assistant', assistantSchema);

// Export the Resume model
module.exports = Assistant;
