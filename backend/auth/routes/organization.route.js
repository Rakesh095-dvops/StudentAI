const express = require('express')
const routes = express.Router()
const organizationController = require('../controllers/organization.controller')

routes.get('/', organizationController.getAllOrganizations);
routes.get('/:id', organizationController.getOrganizationById);
routes.post('/', organizationController.createOrganization);
routes.put('/:id', organizationController.updateOrganization);
routes.delete('/:id', organizationController.deleteOrganization);

module.exports = routes;