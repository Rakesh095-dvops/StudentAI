const express = require('express')
const routes = express.Router()
const userController = require('../controllers/user.controller')
const jwtToken = require('../utils/jwtToken')

routes.post('/', userController.registerUser)
routes.post('/verify', userController.verifyOTP)
routes.post('/login', userController.loginUser)
routes.get('/',userController.getAllUser)
routes.get('/:id', userController.getUserDataById)
routes.put('/:id',userController.updateUserData)
routes.delete('/:id',userController.deleteUserById)
routes.post("/verifyAuth", jwtToken.verifyToken);
routes.post('/registerUserOrg', userController.registerUserByBusiness)

module.exports = routes 