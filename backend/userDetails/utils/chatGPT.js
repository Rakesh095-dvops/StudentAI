const { OpenAI } = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function generateCV(userDetails, jobDescription) {
  try {
    // console.log('Request Received: ', userDetails, jobDescription);
    const prompt = `Generate a detailed CV based on the following user details and job description:\n\nUser Details:\nName: ${userDetails.name}\nEmail: ${userDetails.email}\nAbout: ${userDetails.about}\nEducation: ${userDetails.educationQualifications.map(edu => `${edu.degree} in ${edu.specialization} from ${edu.collegeName}, ${edu.years}`).join('\n')}\nProfessional Experience: ${userDetails.professionalQualifications.map(pro => `${pro.role} at ${pro.companyName}, ${pro.description}`).join('\n')}\nSkills: ${userDetails.skills.join(', ')}\nCertifications: ${userDetails.certifications.join(', ')}\nProjects: ${userDetails.projects.map(proj => `${proj.projectName}: ${proj.projectDescription}`).join('\n')}\n\nJob Description:\n${jobDescription}\n\nPlease create a CV that aligns with the job description and suggest any improvements.`;


    const response = await openai.chat.completions.create({
      messages: [{role: "system", content: prompt}],
      model: "gpt-4o", 
      max_tokens: 1500,
      temperature: 0.5
    });

    console.log('CV generated: ', response.choices[0].message)

    const cv = response.choices[0].message;
    const improvements = "Suggested improvements based on the CV generated.";

    return { cv, improvements };
  } catch (error) {
    console.error('Error communicating with OpenAI API:', error);
    throw new Error('Failed to generate CV from OpenAI API.');
  }
}

module.exports = generateCV;
