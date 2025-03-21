const db = require('../config/db');

const Card = {};

// Find a card by user ID
Card.findByUserId = (userId, callback) => {
  const query = 'SELECT * FROM cards WHERE user_id = ?';
  db.query(query, [userId], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    callback(null, results[0]);
  });
};

// Find a card by card number
Card.findByCardNumber = (cardNumber, callback) => {
  const query = 'SELECT * FROM cards WHERE card_number = ?';
  db.query(query, [cardNumber], (err, results) => {
    if (err) {
      return callback(err, null);
    }
    callback(null, results[0]);
  });
};

// Create a new card for a user
Card.create = (userId, cardNumber, callback) => {
  const query = 'INSERT INTO cards (user_id, card_number) VALUES (?, ?)';
  db.query(query, [userId, cardNumber], (err, result) => {
    if (err) {
      return callback(err);
    }
    callback(null, result);
  });
};

module.exports = Card;