const db = require('../utils/conn')
const mongoose = require("../utils/conn").mongoose;

const authlogSchema = mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'users'
    },
    ip: {
        type: String        
    },
    status: {
        type: Boolean
    },
    createdAt: {
        type: Date,
        default: Date.now()
    }
})


const Authlog = mongoose.model('authlog', authlogSchema)
module.exports = { Authlog }