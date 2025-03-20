const User = require('../models/user');
const Transaction = require('../models/transaction');

exports.getBalance = (req, res) => {
    const userId = req.user.userId;
    
    User.findById(userId, (err, user) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json({ balance: user.balance });
    });
};

exports.getTransactions = (req, res) => {
    const userId = req.user.userId;
    
    Transaction.findByUserId(userId, (err, results) => {
        if (err) return res.status(500).json({ error: 'Database error' });
        res.json(results);
    });
};

exports.transferFunds = (req, res) => {
    const senderId = req.user.userId;
    const { amount, recipientEmail } = req.body;

    // Validation
    if (!amount || !recipientEmail) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    if (amount <= 0) {
        return res.status(400).json({ error: 'Invalid amount' });
    }

    // Start transaction
    db.beginTransaction(async (err) => {
        try {
            // 1. Get sender and recipient
            const [sender, recipient] = await Promise.all([
                new Promise((resolve, reject) => User.findById(senderId, (err, user) => err ? reject(err) : resolve(user))),
                new Promise((resolve, reject) => User.findByEmail(recipientEmail, (err, user) => err ? reject(err) : resolve(user)))
            ]);

            if (!recipient) throw new Error('Recipient not found');
            if (sender.balance < amount) throw new Error('Insufficient funds');

            // 2. Update balances
            const newSenderBalance = parseFloat(sender.balance) - parseFloat(amount);
            const newRecipientBalance = parseFloat(recipient.balance) + parseFloat(amount);

            await Promise.all([
                new Promise((resolve, reject) => 
                    db.query('UPDATE users SET balance = ? WHERE id = ?', [newSenderBalance, senderId], 
                    (err) => err ? reject(err) : resolve())
                ),
                new Promise((resolve, reject) => 
                    db.query('UPDATE users SET balance = ? WHERE id = ?', [newRecipientBalance, recipient.id], 
                    (err) => err ? reject(err) : resolve())
                )
            ]);

            // 3. Create transactions
            const transactionData = {
                user_id: senderId,
                amount: -amount,
                type: 'transfer',
                description: `Transfer to ${recipientEmail}`,
                balance_after: newSenderBalance,
                related_user_id: recipient.id
            };

            const recipientTransaction = {
                user_id: recipient.id,
                amount: amount,
                type: 'transfer',
                description: `Transfer from ${sender.email}`,
                balance_after: newRecipientBalance,
                related_user_id: senderId
            };

            await Promise.all([
                new Promise((resolve, reject) => 
                    Transaction.create(transactionData, (err) => err ? reject(err) : resolve())
                ),
                new Promise((resolve, reject) => 
                    Transaction.create(recipientTransaction, (err) => err ? reject(err) : resolve())
                )
            ]);
            

            // Commit transaction
            db.commit((err) => {
                if (err) throw err;
                res.json({ message: 'Transfer successful' });
            });

        } catch (error) {
            db.rollback(() => {
                res.status(400).json({ error: error.message });
            });
        }
    });
};

