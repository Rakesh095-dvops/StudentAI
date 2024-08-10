// Import the UserDetails model
const UserDetails = require("../models/userdetails.model");
const fs = require("fs");
const AWS = require("aws-sdk");
const { Upload } = require("@aws-sdk/lib-storage");

const { S3 } = require("@aws-sdk/client-s3");

AWS.config.update({
  accessKeyId: process.env.AWS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_KEY,
  region: process.env.AWS_REGION,
});

const s3 = new S3({
  credentials: {
    accessKeyId: process.env.AWS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_KEY,
  },

  region: process.env.AWS_REGION,
});
let BUCKET = process.env.AWS_BUCKET;



const { OpenAI } = require('openai');
const openai = new OpenAI();

async function resumeExtractor(file){
    const aapl10k = await openai.files.create({
        file: fs.createReadStream(file),
        purpose: "assistants",
      });
      
      const thread = await openai.beta.threads.create({
        messages: [
          {
            role: "user",
            content:
              "Generate the CV/Resume in the specified json format",
            // Attach the new file to the message.
            attachments: [{ file_id: aapl10k.id, tools: [{ type: "file_search" }] }],
          },
        ],
      });
      
      // The thread now has a vector store in its tool resources.
      console.log(thread.tool_resources?.file_search);
      const run = await openai.beta.threads.runs.createAndPoll(thread.id, {
        assistant_id: 'asst_Kpx3ldREcSC2Kb6IrI1yBysG',
      });
       
      const messages = await openai.beta.threads.messages.list(thread.id, {
        run_id: run.id,
      });
       
      const message = messages.data.pop();
      if(message){
        if (message.content[0].type === "text") {
            const { text } = message.content[0];
            const { annotations } = text;
            const citations = "";
          
            let index = 0;
            for (let annotation of annotations) {
              text.value = text.value.replace(annotation.text, "[" + index + "]");
              const { file_citation } = annotation;
              if (file_citation) {
                const citedFile = await openai.files.retrieve(file_citation.file_id);
                citations.push("[" + index + "]" + citedFile.filename);
              }
              index++;
            }
            // console.log('text.value: ', text.value)
            const jsonMatch = text.value.match(/```json([\s\S]*?)```/);
            if (jsonMatch && jsonMatch[1]) {
                try {
                  const jsonString = jsonMatch[1].trim();
                  console.log('jsonString: ', jsonString);
                  const jsonObject = JSON.parse(jsonString);
                //   console.log('jsonObject: ', jsonObject)
                  return jsonObject
                } catch (error) {
                  console.error('Invalid JSON:', error);
                }
              } else {
                console.error('No JSON found in the text');
              }
          }
      }
    

}
// async function main() {
//     const assistant = await ResumeAssistantGenerator()
//     console.log('Assistant Value: ', assistant.id)
 
// const aapl10k = await openai.files.create({
//     file: fs.createReadStream("./uploads/3dc6aabc46217e8d3afc6b04a0ae53dc1721365418313.pdf"),
//     purpose: "assistants",
//   });
  
//   const thread = await openai.beta.threads.create({
//     messages: [
//       {
//         role: "user",
//         content:
//           "Generate the CV/Resume in the specified json format",
//         // Attach the new file to the message.
//         attachments: [{ file_id: aapl10k.id, tools: [{ type: "file_search" }] }],
//       },
//     ],
//   });
  
//   // The thread now has a vector store in its tool resources.
//   console.log(thread.tool_resources?.file_search);
//   const run = await openai.beta.threads.runs.createAndPoll(thread.id, {
//     assistant_id: assistant.id,
//   });
   
//   const messages = await openai.beta.threads.messages.list(thread.id, {
//     run_id: run.id,
//   });
   
//   const message = messages.data.pop();
//   if(message){
//     if (message.content[0].type === "text") {
//         const { text } = message.content[0];
//         const { annotations } = text;
//         const citations = "";
      
//         let index = 0;
//         for (let annotation of annotations) {
//           text.value = text.value.replace(annotation.text, "[" + index + "]");
//           const { file_citation } = annotation;
//           if (file_citation) {
//             const citedFile = await openai.files.retrieve(file_citation.file_id);
//             citations.push("[" + index + "]" + citedFile.filename);
//           }
//           index++;
//         }
//         console.log('text.value: ', text.value)
//         const jsonMatch = text.value.match(/```json([\s\S]*?)```/);
//         if (jsonMatch && jsonMatch[1]) {
//             try {
//               const jsonString = jsonMatch[1].trim();
//               console.log('jsonString: ', jsonString);
//               const jsonObject = JSON.parse(jsonString);
//               console.log('jsonObject: ', jsonObject)
//             } catch (error) {
//               console.error('Invalid JSON:', error);
//             }
//           } else {
//             console.error('No JSON found in the text');
//           }
        

//       }
//   }
  
// }
 
// main();



// Upload the student resume
const uploadResume = async (req,res) => {
    if (!req.file) {
        return res.status(400).send("No file uploaded");
    }
    try {
        const fileContent = fs.readFileSync(req.file.path);
        console.log('fs: ',req.file.path)
        const params = {
          Bucket: BUCKET,
          Key: `resume/${req.file.originalname}`,
          Body: fileContent,
        };
    
        // S3 ManagedUpload with callbacks are not supported in AWS SDK for JavaScript (v3).
        // Please convert to 'await client.upload(params, options).promise()', and re-run aws-sdk-js-codemod.
        let data = await new Upload({
          client: s3,
          params,
        }).done()
        console.log('Uploded Resume Key: ', data.Key)
        const extractedInfo = await resumeExtractor(req.file.path);
        console.log('Extracted Information: ', extractedInfo);
        // res.send({msg: "File Uploaded successfully"})
        console.log('email: ', extractedInfo.email)
        const { email, ...otherUpdates } = extractedInfo;
        console.log('userId: ',req.user.userId)
        const filter = { userId: req.user.userId };

    // Check if the user details already exist
    const existingUserDetails = await UserDetails.findOne(filter);

    let update = { $set: otherUpdates };
    let options = { new: true, runValidators: true };

    if (!existingUserDetails) {
      // If no existing details, prepare to set email and userId on insert
      update.$setOnInsert = { email: email, userId: req.user.userId };
      options.upsert = true; // Enable upsert only if no document exists
    }

    const userDetails = await UserDetails.findOneAndUpdate(
      filter,
      update,
      options
    );
    res.status(201).send(userDetails);
      } catch (error) {
        return res.status(500).send(`Error uploading file: ${error.message}`);
      }
}


// Add a new user's details
const addUserDetails = async (req, res) => {
  try {
    const { email, ...otherUpdates } = req.body;
    const filter = { userId: req.user.userId };
    console.log("User Details Data: ", req.body);

    // Prepare the update object
    let update = { $set: otherUpdates };
    let options = { new: true, runValidators: true, upsert: true }; // Enable upsert to insert if not found

    // If email is provided, include it in the update (only set on insert)
    if (email) {
      update.$setOnInsert = { email: email, userId: req.user.userId };
    } else {
      update.$setOnInsert = { userId: req.user.userId }; // Always set userId on insert
    }

    // Perform the update or insert operation
    const userDetails = await UserDetails.findOneAndUpdate(
      filter,
      update,
      options
    );
    res.status(201).send(userDetails);
  } catch (error) {
    console.error("Update Error:", error);
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
    const user = await UserDetails.find({ userId: req.params.id });
    console.log("User Data Fetched: ", user[0].professionalQualifications);
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
    const updatedUser = await UserDetails.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );
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
  deleteUserDetailsById,
  uploadResume
};
