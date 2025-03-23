const Profile = require('../models/profile');
const { uploadToStorage } = require('../utils/fileUpload'); // Assuming you have this utility

exports.getProfile = async (req, res) => {
  try {
    // req.user is set by authMiddleware
    const userId = req.user.id;
    
    Profile.findByUserId(userId, (err, profile) => {
      if (err) {
        console.error('Error fetching profile:', err);
        return res.status(500).json({ error: 'Failed to fetch profile' });
      }
      
      if (!profile) {
        return res.status(404).json({ error: 'Profile not found' });
      }
      
      res.status(200).json(profile);
    });
  } catch (err) {
    console.error('Profile fetch error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    let profileData = req.body;
    
    // Handle profile image upload if included
    if (req.file) {
      try {
        const fileUrl = await uploadToStorage(req.file);
        profileData.profileImage = fileUrl;
      } catch (uploadError) {
        console.error('Error uploading profile image:', uploadError);
        return res.status(400).json({ error: 'Failed to upload profile image' });
      }
    }
    
    Profile.update(userId, profileData, (err, updatedProfile) => {
      if (err) {
        console.error('Error updating profile:', err);
        return res.status(400).json({ error: err.message });
      }
      
      res.status(200).json({
        message: 'Profile updated successfully',
        profile: updatedProfile
      });
    });
  } catch (err) {
    console.error('Profile update error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

exports.updatePassword = async (req, res) => {
  try {
    const userId = req.user.id;
    const { currentPassword, newPassword } = req.body;
    
    // Validate input
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: 'Both current and new passwords are required' });
    }
    
    if (newPassword.length < 6) {
      return res.status(400).json({ error: 'New password must be at least 6 characters' });
    }
    
    Profile.updatePassword(userId, { currentPassword, newPassword }, (err, result) => {
      if (err) {
        console.error('Error updating password:', err);
        return res.status(400).json({ error: err.message });
      }
      
      res.status(200).json({
        message: 'Password updated successfully'
      });
    });
  } catch (err) {
    console.error('Password update error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};

// Optional: Get profile by user ID (admin only)
exports.getProfileById = async (req, res) => {
  try {
    // Check if user is admin
    if (!req.user.isAdmin) {
      return res.status(403).json({ error: 'Unauthorized access' });
    }
    
    const userId = req.params.userId;
    
    Profile.findByUserId(userId, (err, profile) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to fetch profile' });
      }
      
      if (!profile) {
        return res.status(404).json({ error: 'Profile not found' });
      }
      
      res.status(200).json(profile);
    });
  } catch (err) {
    console.error('Profile fetch by ID error:', err);
    res.status(500).json({ error: 'Server error' });
  }
};