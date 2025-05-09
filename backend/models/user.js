const db = require('../config/db');
const bcrypt = require('bcryptjs');

const User = {};

// Find user by email (for login)
User.findByEmail = (email, callback) => {
  const query = 'SELECT * FROM users WHERE email = ?';
  db.query(query, [email], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    callback(null, results[0]);
  });
};

// Find user by ID
User.findById = (id, callback) => {
  const query = 'SELECT * FROM users WHERE id = ?';
  db.query(query, [id], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    callback(null, results[0]);
  });
};

// Create a new user
User.create = (userData, callback) => {
  bcrypt.hash(userData.password, 10, (err, hash) => {
    if (err) return callback(err);

    const query = `
      INSERT INTO users (first_name, last_name, email, phone, password) 
      VALUES (?, ?, ?, ?, ?)
    `;
    db.query(
      query,
      [userData.firstName, userData.lastName, userData.email, userData.phone, hash],
      (err, result) => {
        if (err) return callback(err);
        callback(null, result);
      }
    );
  });
};

// Update user balance
User.updateBalance = (userId, newBalance, callback) => {
  const query = 'UPDATE users SET balance = ? WHERE id = ?';
  db.query(query, [newBalance, userId], (err, result) => {
    if (err) {
      return callback(err);
    }
    callback(null, result);
  });
};

// Compare password
User.comparePassword = (candidatePassword, hash, callback) => {
  bcrypt.compare(candidatePassword, hash, (err, isMatch) => {
    if (err) return callback(err);
    callback(null, isMatch);
  });
};

module.exports = User;