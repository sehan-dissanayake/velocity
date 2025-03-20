const db = require('../config/db');

const Transaction = {
    create: (transactionData, callback) => {
        const query = `
            INSERT INTO transactions 
            (user_id, amount, type, description, balance_after, related_user_id)
            VALUES (?, ?, ?, ?, ?, ?)
        `;
        db.query(query, [
            transactionData.user_id,
            transactionData.amount,
            transactionData.type,
            transactionData.description,
            transactionData.balance_after,
            transactionData.related_user_id || null
        ], callback);
    },

    findByUserId: (userId, callback) => {
        const query = `
            SELECT * FROM transactions 
            WHERE user_id = ? 
            ORDER BY created_at DESC
        `;
        db.query(query, [userId], callback);
    }
};

module.exports = Transaction;