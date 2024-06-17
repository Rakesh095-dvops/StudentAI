const db = require('../utils/conn')
const mongoose = require("../utils/conn").mongoose;

const authenticationSchema = mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users'
    },
    otp: {
        type: Number
    },
    isVerified: {
        type: Boolean
    },
    attempt: {
        type: Number
    },
    createdAt: {
        type: Date,
        default: Date.now()
    }
})


const Auth = mongoose.model('auth', authenticationSchema)
module.exports = { Auth }