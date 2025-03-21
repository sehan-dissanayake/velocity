const User = require('../models/user');
const Card = require('../models/card');
const Transaction = require('../models/transaction');
const db = require('../config/db');

exports.getWallet = (req, res) => {
  if (!req.user || !req.user.id) {
    return res.status(401).json({ message: 'User not authenticated' });
  }

  User.findById(req.user.id, (err, user) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    Card.findByUserId(user.id, (err, card) => {
      if (err) {
        return res.status(500).json({ message: err.message });
      }

      if (!card) {
        // Generate a unique card number
        let cardNumber;
        const generateCardNumber = () => {
          cardNumber = Math.floor(1000000000 + Math.random() * 9000000000).toString();
          Card.findByCardNumber(cardNumber, (err, existingCard) => {
            if (err) {
              return res.status(500).json({ message: err.message });
            }
            if (existingCard) {
              // Card number already exists, try again
              generateCardNumber();
            } else {
              // Create the card
              Card.create(user.id, cardNumber, (err, result) => {
                if (err) {
                  return res.status(500).json({ message: err.message });
                }
                res.json({
                  card_number: cardNumber,
                  balance: user.balance,
                });
              });
            }
          });
        };
        generateCardNumber();
      } else {
        res.json({
          card_number: card.card_number,
          balance: user.balance,
        });
      }
    });
  });
};

exports.getTransactions = (req, res) => {
  if (!req.user || !req.user.id) {
    return res.status(401).json({ message: 'User not authenticated' });
  }

  Transaction.findByUserId(req.user.id, (err, transactions) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }
    res.json(transactions);
  });
};

exports.transfer = (req, res) => {
  if (!req.user || !req.user.id) {
    return res.status(401).json({ message: 'User not authenticated' });
  }

  const { recipient_card_number, amount } = req.body;
  if (!recipient_card_number || !amount) {
    return res.status(400).json({ message: 'Missing required fields' });
  }
  if (amount <= 0) {
    return res.status(400).json({ message: 'Amount must be positive' });
  }

  // Start a transaction
  db.query('START TRANSACTION', (err) => {
    if (err) {
      return res.status(500).json({ message: err.message });
    }

    // Fetch sender
    User.findById(req.user.id, (err, sender) => {
      if (err) {
        db.query('ROLLBACK');
        return res.status(500).json({ message: err.message });
      }
      if (!sender) {
        db.query('ROLLBACK');
        return res.status(404).json({ message: 'Sender not found' });
      }
      if (sender.balance < amount) {
        db.query('ROLLBACK');
        return res.status(400).json({ message: 'Insufficient balance' });
      }

      // Fetch recipient card
      Card.findByCardNumber(recipient_card_number, (err, recipientCard) => {
        if (err) {
          db.query('ROLLBACK');
          return res.status(500).json({ message: err.message });
        }
        if (!recipientCard) {
          db.query('ROLLBACK');
          return res.status(404).json({ message: 'Recipient not found' });
        }

        // Fetch recipient user
        User.findById(recipientCard.user_id, (err, recipient) => {
          if (err) {
            db.query('ROLLBACK');
            return res.status(500).json({ message: err.message });
          }
          if (!recipient) {
            db.query('ROLLBACK');
            return res.status(404).json({ message: 'Recipient user not found' });
          }

          // Update balances
          const newSenderBalance = sender.balance - amount;
          const newRecipientBalance = recipient.balance + amount;

          User.updateBalance(sender.id, newSenderBalance, (err) => {
            if (err) {
              db.query('ROLLBACK');
              return res.status(500).json({ message: err.message });
            }

            User.updateBalance(recipient.id, newRecipientBalance, (err) => {
              if (err) {
                db.query('ROLLBACK');
                return res.status(500).json({ message: err.message });
              }

              // Create sender transaction
              Transaction.create(
                {
                  user_id: sender.id,
                  type: 'transfer_sent',
                  amount: -amount,
                  balance_after: newSenderBalance,
                },
                (err) => {
                  if (err) {
                    db.query('ROLLBACK');
                    return res.status(500).json({ message: err.message });
                  }

                  // Create recipient transaction
                  Transaction.create(
                    {
                      user_id: recipient.id,
                      type: 'transfer_received',
                      amount: amount,
                      balance_after: newRecipientBalance,
                    },
                    (err) => {
                      if (err) {
                        db.query('ROLLBACK');
                        return res.status(500).json({ message: err.message });
                      }

                      // Commit the transaction
                      db.query('COMMIT', (err) => {
                        if (err) {
                          db.query('ROLLBACK');
                          return res.status(500).json({ message: err.message });
                        }
                        res.json({ message: 'Transfer successful' });
                      });
                    }
                  );
                }
              );
            });
          });
        });
      });
    });
  });
};