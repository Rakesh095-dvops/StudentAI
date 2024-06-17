const jwt = require("jsonwebtoken");

const generateToken = (userId, userType) => {
  const payload = {
    userId,
    userType
  };
  const token = jwt.sign(payload, process.env.JWT_TOKEN, { expiresIn: "12h" });

  return token;
};

const verifyToken = (token) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_TOKEN);
    return decoded;
  } catch (error) {
    console.error(error);
    return null;
  }
};

module.exports = {generateToken, verifyToken}
