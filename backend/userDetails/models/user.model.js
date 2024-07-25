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
  organization: {
    type: String,
    default: "others"
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
  createdAt: {
    type: Date,
    default: Date.now(),
  },
});

const User = mongoose.model("user", userSchema);
module.exports = { User };
