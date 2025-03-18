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

User.create = (userData, callback) => {
    bcrypt.hash(userData.password, 10, (err, hash) => {
        if (err) return callback(err);
        
        const query = 'INSERT INTO users (email, password) VALUES (?, ?)';
        db.query(query, [userData.email, hash], callback);
    });
};

User.comparePassword = (candidatePassword, hash, callback) => {
    bcrypt.compare(candidatePassword, hash, (err, isMatch) => {
        if (err) return callback(err);
        callback(null, isMatch);
    });
};


module.exports = User;
