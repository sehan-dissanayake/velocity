const jwt = require('jsonwebtoken');

exports.generateToken = (userData) => {
  return jwt.sign(
    { id: userData.id, email: userData.email },
    process.env.JWT_SECRET || 'velociti',
    { expiresIn: '24h' }
  );
};

exports.verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET || 'velociti');
  } catch (error) {
    return null;
  }
};