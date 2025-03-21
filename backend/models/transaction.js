const db = require('../config/db');

const Transaction = {};

// Find all transactions for a user, ordered by date descending
Transaction.findByUserId = (userId, callback) => {
  const query = `
    SELECT * FROM transactions 
    WHERE user_id = ? 
    ORDER BY transaction_date DESC
  `;
  db.query(query, [userId], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    callback(null, results);
  });
};

// Create a new transaction
Transaction.create = (transactionData, callback) => {
  const query = `
    INSERT INTO transactions (user_id, type, amount, balance_after) 
    VALUES (?, ?, ?, ?)
  `;
  db.query(
    query,
    [
      transactionData.user_id,
      transactionData.type,
      transactionData.amount,
      transactionData.balance_after,
    ],
    (err, result) => {
      if (err) {
        return callback(err);
      }
      callback(null, result);
    }
  );
};

module.exports = Transaction;