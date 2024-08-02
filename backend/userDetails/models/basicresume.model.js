// Import the mongoose module from the utils folder
const { mongoose } = require("../utils/conn");

// Define the schema for the Resume
const basicResumeSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "UserDetails", // Assuming UserDetails is the model where user data is stored
    required: true,
  },
  generatedCV: {
    type: Object,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now(),
  },
});

// Create a model from the schema
const BasicResume = mongoose.model("BasicResume", basicResumeSchema);

// Export the Resume model
module.exports = BasicResume;
