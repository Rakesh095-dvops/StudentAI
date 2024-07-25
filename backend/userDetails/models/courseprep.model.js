// Import the mongoose module from the utils folder
const { mongoose } = require('../utils/conn');

// Define the schema for the Resume
const courseSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'UserDetails', // Assuming UserDetails is the model where user data is stored
        required: true
    },
    resumeId: {
        type: String
    },
    learningPath: [
        {
            moduleName: {type: String},
            durationToComplete: {type: String},
            moduleObjective: {type: String},
            topics: [
                    {
                        topicName: {type: String},
                        learningContent: [
                            {
                                subtopicName: {type: String},
                                detailedConcept: {type: String},
                                caseStudy: {type: String},     
                             }
                         ],
                         practiceSampleProjectToWork: {type: String},
                    }
                ],
            practiceQuestion: [
                  {
                     question: {type: String},
                     answer: {type: String}
                   }
              ]
         }
    ]
});

// Create a model from the schema
const CoursePrep = mongoose.model('Course', courseSchema);

// Export the Resume model
module.exports = CoursePrep;
