const jwt = require('jsonwebtoken');
require('dotenv').config();

const authMiddleware = (req, res, next) => {
  // Get token from Authorization header
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authorization header missing or invalid' });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Token missing' });
  }

  try {
    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'velociti');
    if (!decoded.id) {
      return res.status(401).json({ message: 'Invalid token payload: missing user ID' });
    }
    req.user = decoded; // Set user data on req.user (e.g., { id: 1, email: 'user@example.com' })
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token', error: error.message });
  }
};

const generateToken = (userData) => {
  return jwt.sign(
    { id: userData.id, email: userData.email },
    process.env.JWT_SECRET || 'velociti',
    { expiresIn: '24h' }
  );
};

const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET || 'velociti');
  } catch (error) {
    return null;
  }
};

module.exports = { authMiddleware, generateToken, verifyToken };
