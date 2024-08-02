const db = require("../utils/conn");
const mongoose = require("../utils/conn").mongoose;

const userSchema = mongoose.Schema({
  name: {
    type: String,
    required: true,
    minlength: 1,
    maxlength: 50,
  },
  email: {
    type: String,
    required: true,
    minlength: 3,
    maxlength: 50,
    unique: true,
    index: true,
  },
  phoneNo: {
    type: String,
    required: true,
    minlength: 7,
    maxlength: 18,
  },
  userType: {
    type: String,
    required: true,
    default: "student",
    enum: ["student", "admin", "organization"],
  },
  accountStatus: {
    type: String,
    default: "onhold",
    enum: ["active", "onhold"],
  },
  organization: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Organization",
    default: new mongoose.Types.ObjectId('66aa198aecdaa2f5e6ce025d')
  },
  createdAt: {
    type: Date,
    default: Date.now(),
  },
});

const User = mongoose.model("user", userSchema);
module.exports = { User };
