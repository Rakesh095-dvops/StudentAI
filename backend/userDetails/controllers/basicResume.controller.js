const BasicResume = require("../models/basicresume.model");
const UserDetails = require("../models/userdetails.model");
const generateBasicCV = require("../utils/chatGPT");

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

const { OpenAI } = require("openai");
const openai = new OpenAI();

async function resumeExtractor(file) {
  const aapl10k = await openai.files.create({
    file: fs.createReadStream(file),
    purpose: "assistants",
  });

  const thread = await openai.beta.threads.create({
    messages: [
      {
        role: "user",
        content: "Generate the CV/Resume in the specified json format",
        // Attach the new file to the message.
        attachments: [
          { file_id: aapl10k.id, tools: [{ type: "file_search" }] },
        ],
      },
    ],
  });

  // The thread now has a vector store in its tool resources.
  console.log(thread.tool_resources?.file_search);
  const run = await openai.beta.threads.runs.createAndPoll(thread.id, {
    assistant_id: "asst_Kpx3ldREcSC2Kb6IrI1yBysG",
  });

  const messages = await openai.beta.threads.messages.list(thread.id, {
    run_id: run.id,
  });

  const message = messages.data.pop();
  if (message) {
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
      console.log('text.value: ', text.value)
      const jsonMatch = text.value.match(/```json([\s\S]*?)```/);
      if (jsonMatch && jsonMatch[1]) {
        try {
          const jsonString = jsonMatch[1].trim();
          console.log("jsonString: ", jsonString);
          const jsonObject = JSON.parse(jsonString);
          //   console.log('jsonObject: ', jsonObject)
          return jsonObject;
        } catch (error) {
          console.error("Invalid JSON:", error);
        }
      } else {
        console.error("No JSON found in the text");
      }
    }
  }
}

const uploadResumeByBusiness = async (req, res) => {
  if (!req.file) {
    console.log("userId: ", req.params.uid);
    return res.status(400).send("No file uploaded");
  }
  try {
    console.log("userId: ", req.params.uid);
    const fileContent = fs.readFileSync(req.file.path);
    console.log("fs: ", req.file.path);
    const params = {
      Bucket: BUCKET,
      Key: `resume/${req.file.originalname}`,
      Body: fileContent,
    };
    let data = await new Upload({
      client: s3,
      params,
    }).done();
    console.log("Uploded Resume Key: ", data.Key);
    const extractedInfo = await resumeExtractor(req.file.path);
    // console.log("Extracted Information: ", extractedInfo);    
    console.log("email: ", extractedInfo.email);
    const { email, ...otherUpdates } = extractedInfo;
    const filter = { userId: req.params.uid };

    const existingUserDetails = await UserDetails.findOne(filter);
    console.log('existingUserDetails: ', existingUserDetails)

    let update = { $set: otherUpdates };
    let options = { new: true, runValidators: true };

    if (!existingUserDetails) {
      update.$setOnInsert = { email: email, userId: req.params.uid };
      options.upsert = true;
    }

    const userDetails = await UserDetails.findOneAndUpdate(
      filter,
      update,
      options
    );
    res.status(201).send(userDetails);
  } catch (error) {
        res.status(500).send({"msg": `Error uploading file: ${error.message}`});
  }
};

const basicCreateCV = async (req, res) => {
  try {
    let userId = req.user.userId;
    const userDetails = await UserDetails.find({ userId: userId });
    if (!userDetails) {
      return res.status(404).send({ message: "User not found" });
    }
    console.log("User Found: ", userDetails);
    const { parsedData } = await generateBasicCV(userDetails);
    console.log("Basic CV: ", parsedData);
    const newResume = new BasicResume({
      userId,
      generatedCV: JSON.stringify(parsedData),
    });
    await newResume.save();

    res.status(201).send(newResume);
  } catch (error) {
    res.status(500).send({ message: "Error generating CV", error });
  }
};

const basicCreateCVByBusiness = async (req, res) => {
  try {
    let userId = req.body.userId;
    const userDetails = await UserDetails.find({ userId: userId });
    if (!userDetails) {
      return res.status(404).send({ message: "User not found" });
    }
    console.log("User Found: ", userDetails);
    const { parsedData } = await generateBasicCV(userDetails);
    console.log("Basic CV: ", parsedData);
    const newResume = new BasicResume({
      userId,
      generatedCV: JSON.stringify(parsedData),
    });
    await newResume.save();

    res.status(201).send(newResume);
  } catch (error) {
    res.status(500).send({ message: "Error generating CV", error });
  }
};

const getBasicResumeById = async (req, res) => {
  try {
    const { id } = req.params;
    const resume = await BasicResume.findById(id);
    if (!resume) {
      return res.status(404).send({ message: "Resume not found" });
    }
    res.status(200).send(resume);
  } catch (error) {
    res.status(500).send({ message: "Error fetching resume", error });
  }
};

const getBasicAllResumes = async (req, res) => {
  try {
    const resumes = await BasicResume.find();
    res.status(200).send(resumes);
  } catch (error) {
    res.status(500).send({ message: "Error fetching resumes", error });
  }
};

// Export the controller function
module.exports = {
  basicCreateCV,
  getBasicResumeById,
  getBasicAllResumes,
  basicCreateCVByBusiness,
  uploadResumeByBusiness,
};
