// jwtMiddleware.js
const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: "Access denied. Token is missing." });
  }

  const token = authHeader.split(' ')[1]; // Split the "Bearer <token>" string and get the token part
  console.log('Token received: ', token)
  if (!token) {
    return res.status(401).json({ error: "Access denied. Token is missing." });
  }

  if (!token) {
    return res.status(401).json({ error: "Access denied. Token is missing." });
  }

  

  try {
    const decoded = jwt.verify(token, process.env.JWT_TOKEN);
    req.user = decoded;
    console.log("user:", req.user);

    // Extract userType and add it to the request object
    req.userType = decoded.userType;
    console.log("userType:", req.userType);

    next();
  } catch (error) {
    console.error(error);
    res.status(401).json({ error: "Invalid token." });
  }
};

module.exports = verifyToken;