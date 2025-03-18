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
