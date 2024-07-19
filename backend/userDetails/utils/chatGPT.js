const { OpenAI } = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

function extractAndParseJSON(content) {
  const jsonString = content.match(/```json([\s\S]*)```/)[1];
  return JSON.parse(jsonString);
}

async function generateCV(userDetails, jobDescription) {
  try {
    userDetails = userDetails[0]; // Safely accessing user details properties
    const name = userDetails.name || 'N/A';
    const email = userDetails.email || 'N/A';
    const phoneNo = userDetails.contactDetails?.phone || 'N/A';
    const currentJobTitle = userDetails.currentJobTitle || 'N/A';
    const education = Array.isArray(userDetails.educationQualifications) ? userDetails.educationQualifications.map(edu => ({
      degree: edu.degree,
      institution: edu.collegeName,
      year: edu.years,
      specialization: edu.specialization
    })) : [];
    const professionalExperience = Array.isArray(userDetails.professionalQualifications) ? userDetails.professionalQualifications.map(pro => ({
      position: pro.role,
      company: pro.companyName,
      location: pro.location || 'N/A',
      duration: `${pro.duration.from}-${pro.duration.to}`,
      responsibilities: pro.description ? pro.description.split('\n') : []
    })) : [];
    const skills = Array.isArray(userDetails.skills) ? userDetails.skills.map(skill => skill.value) : [];
    const certifications = Array.isArray(userDetails.certifications) ? userDetails.certifications.map(cert => ({
      name: cert.certificationName,
      issuer: cert.certificationIssuer
    })) : [];
    const projects = Array.isArray(userDetails.projects) ? userDetails.projects.map(proj => ({
      title: proj.projectName,
      description: proj.projectDescription,
      details: 'Provide a detailed description of the project, including your role, technologies used, and outcomes.'
    })) : [];

    const prompt = `Generate a detailed CV in the JSON format based on the following user details and job description:\n\nUser Details:\nName: ${name}\nEmail: ${email}\nPhone No: ${phoneNo}\nCurrent Job Title: ${currentJobTitle}\nEducation: ${JSON.stringify(education, null, 2)}\nProfessional Experience: ${JSON.stringify(professionalExperience, null, 2)}\nSkills: ${JSON.stringify(skills, null, 2)}\nCertifications: ${JSON.stringify(certifications, null, 2)}\nProjects: ${JSON.stringify(projects, null, 2)}\n\nJob Description:\n${jobDescription}\n\nPlease create a CV in the following JSON format, ensuring the keys and structure match exactly as described in the below example json format. You can tweak the details of professional qualification, projects to align more with the job description. You can add few things from your side. Also, suggest what skills to improve under the key "suggestedImprovements", only include suggestion in the suggestedImprovements field.\n\n
    While creating the CV make sure you highlight the important key skills in various places in the project details, professional experience, etc. In the duration for professional experience only specify the month and year, also arrange them in descending order when its the professional experience and education.\n\n
    You also need to generate the about section by yourself.\n\n
    Make sure the about, skills, responsibilites in the professional experience, descriptions and details in projects are all aligned with the skills required in job description. Modify the professional experience which should include the blend of current knowledge entered by the learner and the expected experience which he knows.\n\n
    In the suggestion you can specify the suggested project the person can work on in order to improve. The project details can consist of skills required in job description aligned with the project. (In other words, try to stuff the skills required in job description along with the actual skill to be included in project)\n\n
    You will also have to generate a coverletter to be sent under the coverletter tag. Coverletter should clearly highlight the skill possessed, it should also mention the name of the company for which it is applying which is specified under companyNameApplyingFor. At the bottom it should clearly highlight the name, email and phone no.\n\n
    Match the existing data which I am providing against the Job Description and tell me in how much you are ready out of 10. and put that inside the value currentPrep\n\n
    If the currentPrep score is less than 7 then put the value of isEligibleForJob as false.\n\n
    While checking the validity also check the eligibility criteria about years of experience or education if specified in job description. Put these recommendations in improvements.\n\n
    Divide the improvements into further two criteria, technicalImprovement and generalImprovement. technicalImprovement will have the skills which is required to gain. generalImprovement will have the general skills required to work on this job.\n\n
    You cannot generate a new professional experience or new project, but you can tweak existing one. You cannot generate a new certification or new education. You have to be very consistent with the generation of JSON which should strictly follow the below format.:\n\n
    {
    "currentPrep":4
  "isEligibleForJob": true,
  "companyNameApplyingFor": "",
  "jobDescription": "",
  "name": "",
  "email": "",
  "phoneNo": "",
  "about": "",
  "currentJobTitle": "",
  "education": [{
    "degree": "",
    "institution": "",
    "year": '',
    specialization: ""
  }],
  "professionalExperience": [
    {
      "position": "",
      "company": "",
      "location": "",
      "duration": "",
      "responsibilities": [
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
      ]
    }
  ],
  "skills": [
    "Sample skill 1",
    "Sample Skill 2
  ],
  "certifications": [
    {
      "name": "",
      "issuer": ""
    }
  ],
  "projects": [
    {
      "title": "",
      "description": "",
      "details": ""
    }
  ],
  "specialAchievements": [
  "",
  ""
  ]
  "coverletter": "",
  "improvements": {
    "technicalImprovements": "",
    "generalImprovements": ""
  }
}`;

console.log('Prompts: ', prompt)

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [{ role: "system", content: prompt }],
      max_tokens: 4000,
      temperature: 0.5
    });

    const cvContent = response.choices[0].message.content;
    console.log('Raw CV Content:', cvContent);
    const parsedData = extractAndParseJSON(cvContent);
    console.log('parsedData: ', parsedData)

    return { parsedData, improvements: parsedData.improvements };
  } catch (error) {
    console.error('Error communicating with OpenAI API:', error);
    throw new Error('Failed to generate CV from OpenAI API.');
  }
}

async function processResume (file, res){

}


module.exports = generateCV;
