const User = require('../models/user');
const { generateToken } = require('../middleware/authMiddleware');

exports.login =async (req, res) => {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    User.findByEmail(email, async (err, user) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        
        if (!user) return res.status(401).json({ error: 'Invalid credentials' });

        const isMatch = await new Promise((resolve, reject) => {
            User.comparePassword(password, user.password, (err, isMatch) => {
                if (err) reject(err);
                resolve(isMatch);
            });
        });

        if (!isMatch) return res.status(401).json({ error: 'Invalid credentials' });

        // Generate JWT token
        const token = generateToken(user);

        // Return token and user info
        return res.status(200).json({
            message: 'Login successful',
            token,
            user: { id: user.id, email: user.email }
        });
    });
};