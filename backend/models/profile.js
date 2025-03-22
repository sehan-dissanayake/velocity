const db = require('../config/db');

class Profile {
  static findByUserId(userId, callback) {
    const query = `
      SELECT 
        u.id, 
        u.email, 
        u.first_name, 
        u.last_name, 
        u.phone,
        u.created_at
      FROM users u
      WHERE u.id = ?
    `;
    
    db.query(query, [userId], (err, results) => {
      if (err) {
        return callback(err, null);
      }
      if (results.length === 0) {
        return callback(null, null);
      }
      
      // Convert snake_case to camelCase for frontend
      const profile = {
        id: results[0].id,
        email: results[0].email,
        firstName: results[0].first_name,
        lastName: results[0].last_name,
        phone: results[0].phone,
        profileImage: results[0].profile_image,
        createdAt: results[0].created_at,
        updatedAt: results[0].updated_at,
        stats: {
          totalTrips: results[0].total_trips,
          totalDistance: results[0].total_distance
        }
      };
      
      callback(null, profile);
    });
  }
  
  static update(userId, profileData, callback) {
    // First check if the user exists
    const checkQuery = 'SELECT id FROM users WHERE id = ?';
    
    db.query(checkQuery, [userId], (err, checkResults) => {
      if (err) {
        return callback(err, null);
      }
      
      if (checkResults.length === 0) {
        return callback(new Error('User not found'), null);
      }
      
      // Prepare update fields (filter out id and sensitive fields)
      const { firstName, lastName, phone, profileImage } = profileData;
      const updateQuery = `
        UPDATE users
        SET 
          first_name = ?,
          last_name = ?,
          phone = ?
        WHERE id = ?
      `;
      
      db.query(
        updateQuery, 
        [firstName, lastName, phone, userId],
        (err, result) => {
          if (err) {
            return callback(err, null);
          }
          
          // Return the updated user by fetching the profile
          this.findByUserId(userId, callback);
        }
      );
    });
  }
  
  // Method to update password separately with verification
  static updatePassword(userId, { currentPassword, newPassword }, callback) {
    // Verify current password first
    const verifyQuery = 'SELECT password FROM users WHERE id = ?';
    
    db.query(verifyQuery, [userId], (err, results) => {
      if (err) {
        return callback(err, null);
      }
      
      if (results.length === 0) {
        return callback(new Error('User not found'), null);
      }
      
      const storedPassword = results[0].password;
      
      // Use the same password comparison from User model
      const bcrypt = require('bcrypt');
      bcrypt.compare(currentPassword, storedPassword, (err, isMatch) => {
        if (err) {
          return callback(err, null);
        }
        
        if (!isMatch) {
          return callback(new Error('Current password is incorrect'), null);
        }
        
        // Hash the new password
        bcrypt.hash(newPassword, 10, (err, hashedPassword) => {
          if (err) {
            return callback(err, null);
          }
          
          // Update the password
          const updateQuery = `
            UPDATE users
            SET password = ?, updated_at = NOW()
            WHERE id = ?
          `;
          
          db.query(updateQuery, [hashedPassword, userId], (err, result) => {
            if (err) {
              return callback(err, null);
            }
            
            callback(null, { success: true });
          });
        });
      });
    });
  }
}

module.exports = Profile;