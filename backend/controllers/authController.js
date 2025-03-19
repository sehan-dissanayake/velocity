const User = require('../models/user');
const jwt = require('jsonwebtoken');

// Login controller
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        const user = await new Promise((resolve, reject) => {
            User.findByEmail(email, (err, user) => {
                if (err) reject(err);
                resolve(user);
            });
        });

        if (!user) return res.status(401).json({ error: 'Invalid credentials' });

        const isMatch = await new Promise((resolve, reject) => {
            User.comparePassword(password, user.password, (err, isMatch) => {
                if (err) reject(err);
                resolve(isMatch);
            });
        });

        if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });

        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.status(200).json({
            message: 'Login successful',
            token,
            user: { id: user.id, email: user.email }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};

// Signup controller
exports.signup = async (req, res) => {
    try {
        const { firstName, lastName, email, phone, password } = req.body;

        // Validate required fields
        if (!firstName || !lastName || !email || !phone || !password) {
            return res.status(400).json({ error: 'All fields are required' });
        }

        // Check if email already exists
        const existingUser = await new Promise((resolve, reject) => {
            User.findByEmail(email, (err, user) => {
                if (err) reject(err);
                resolve(user);
            });
        });

        if (existingUser) {
            return res.status(400).json({ error: 'Email already in use' });
        }

        // Create new user
        const newUser = await new Promise((resolve, reject) => {
            User.create(
                { firstName, lastName, email, phone, password },
                (err, result) => {
                    if (err) reject(err);
                    // result is the MySQL insert result, not the full user object
                    resolve({ id: result.insertId, email }); // Extract inserted ID
                }
            );
        });

        // Generate JWT token
        const token = jwt.sign(
            { userId: newUser.id, email: newUser.email },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.status(201).json({
            message: 'Signup successful',
            token,
            user: { id: newUser.id, email: newUser.email }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server error' });
    }
};