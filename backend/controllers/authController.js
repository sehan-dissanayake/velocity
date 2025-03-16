const User = require('../models/user');

// Login controller
exports.login = (req, res) => {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    User.findByEmail(email, (err, user) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }
        if (!user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Compare provided password with stored password.
        // In production, use hashed passwords and a library like bcrypt.
        if (password !== user.password) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        // Successful login: return a message (or token, if implementing authentication)
        return res.status(200).json({
            message: 'Login successful',
            user: { id: user.id, email: user.email }
        });
    });
};
