const db = require("../utils/conn");
const mongoose = require("../utils/conn").mongoose;

const organizationSchema = mongoose.Schema({
  organizationName: {
    type: String,
    required: true
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
  createdAt: {
    type: Date,
    default: Date.now(),
  },
});

const Organization = mongoose.model("organization", organizationSchema);
module.exports = { Organization };
