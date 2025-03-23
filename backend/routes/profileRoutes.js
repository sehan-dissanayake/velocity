const express = require('express');
const router = express.Router();
const profileController = require('../controllers/profileController');
const { authMiddleware } = require('../middleware/authMiddleware');
const multer = require('multer');

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  },
});

// All routes require auth
router.use(authMiddleware);

// GET /api/profile - Get current user profile
router.get('/', profileController.getProfile);

// PUT /api/profile - Update current user profile
router.put('/', upload.single('profileImage'), profileController.updateProfile);

// PUT /api/profile/password - Update password
router.put('/password', profileController.updatePassword);

// GET /api/profile/:userId - Get profile by ID (admin only)
router.get('/:userId', profileController.getProfileById);

module.exports = router;