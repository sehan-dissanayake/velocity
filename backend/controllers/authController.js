const User = require('../models/user');
const { generateToken } = require('../middleware/authMiddleware');

// Login controller
exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate input
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        // Find user by email
        const user = await new Promise((resolve, reject) => {
            User.findByEmail(email, (err, user) => {
                if (err) reject(err);
                resolve(user);
            });
        });

        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Compare password
        const isMatch = await new Promise((resolve, reject) => {
            User.comparePassword(password, user.password, (err, isMatch) => {
                if (err) reject(err);
                resolve(isMatch);
            });
        });

        if (!isMatch) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate JWT token
        const token = generateToken(user);

        // Return token and user info
        return res.status(200).json({
            message: 'Login successful',
            token,
            user: { id: user.id, email: user.email }
        });
    } catch (err) {
        console.error('Login error:', err);
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
        const result = await new Promise((resolve, reject) => {
            User.create(
                { firstName, lastName, email, phone, password },
                (err, result) => {
                    if (err) reject(err);
                    resolve(result); // result is the MySQL query result
                }
            );
        });

        // Check if result is valid
        if (!result || !result.insertId) {
            throw new Error('Failed to create user: No insertId returned');
        }

        const newUser = { id: result.insertId, email };

        // Generate JWT token
        const token = generateToken(newUser);

        res.status(201).json({
            message: 'Signup successful',
            token,
            user: { id: newUser.id, email: newUser.email }
        });
    } catch (err) {
        console.error('Signup error:', err);
        res.status(500).json({ error: 'Server error: ' + err.message });
    }
};