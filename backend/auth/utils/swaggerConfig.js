const swaggerJsdoc = require('swagger-jsdoc');
const path = require('path');
const fs = require('fs');

const userControllerPath = path.resolve(__dirname, '../controllers/user.controller.js')
const userControllerContent = fs.readFileSync(userControllerPath, 'utf-8')



const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Batch API',
      version: '1.0.0',
      description: 'API documentation for the Batch controller',
    },
  },
  apis: [userControllerPath],
  content: userControllerContent,
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
