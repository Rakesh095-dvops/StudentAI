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
    // Safely accessing user details properties
    console.log('userData in my generateCV: ', userDetails)
    userDetails = userDetails[0]
    const name = userDetails.name || 'N/A';
    const email = userDetails.email || 'N/A';
    const about = userDetails.about || 'N/A';
    const education = Array.isArray(userDetails.educationQualifications) ? userDetails.educationQualifications.map(edu => `${edu.degree} in ${edu.specialization} from ${edu.collegeName}, ${edu.years}`).join('\n') : 'N/A';
    const professionalExperience = Array.isArray(userDetails.professionalQualifications) ? userDetails.professionalQualifications.map(pro => `${pro.role} at ${pro.companyName}, ${pro.description}`).join('\n') : 'N/A';
    const skills = Array.isArray(userDetails.skills) ? userDetails.skills.map(skill => skill.value).join(', ') : 'N/A';
    const certifications = Array.isArray(userDetails.certifications) ? userDetails.certifications.join(', ') : 'N/A';
    const projects = Array.isArray(userDetails.projects) ? userDetails.projects.map(proj => `${proj.projectName}: ${proj.projectDescription}`).join('\n') : 'N/A';

    const prompt = `Generate a detailed CV in the JSON format based on the following user details and job description:\n\nUser Details:\nName: ${name}\nEmail: ${email}\nAbout: ${about}\nEducation: ${education}\nProfessional Experience: ${professionalExperience}\nSkills: ${skills}\nCertifications: ${certifications}\nProjects: ${projects}\n\nJob Description:\n${jobDescription}\n\nPlease create a CV that aligns with the job description and suggest any improvements where the key should be suggestedImprovements for all the improvements suggested and rest everything should be nested inside the key generatedCV.`;

    console.log('Prompt generated: ', prompt);

    const response = await openai.chat.completions.create({
      messages: [{ role: "system", content: prompt }],
      model: "gpt-4o",
      max_tokens: 4000,
      temperature: 0.5
    });

    console.log('CV generated: ', response.choices[0].message);

    const cv = response.choices[0].message;
    
    
    const parsedData = extractAndParseJSON(cv.content);
    console.log('ParsedData: ', parsedData)
    console.log('type of: ', typeof parsedData)
    const improvements = "Suggested improvements based on the CV generated.";


    return { parsedData, improvements };
  } catch (error) {
    console.error('Error communicating with OpenAI API:', error);
    throw new Error('Failed to generate CV from OpenAI API.');
  }
}


module.exports = generateCV;
