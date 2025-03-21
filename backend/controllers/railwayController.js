const db = require('../config/db');

// Get all railway stations
exports.getAllStations = async (req, res) => {
    try {
        const query = 'SELECT * FROM railway_stations';
        db.query(query, (err, results) => {
            if (err) {
                console.error('Database error:', err);
                return res.status(500).json({ error: 'Database error' });
            }
            res.status(200).json(results);
        });
    } catch (err) {
        console.error('Server error:', err);
        res.status(500).json({ error: 'Server error' });
    }
};