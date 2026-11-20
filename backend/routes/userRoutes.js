const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

// Customer favorite endpoints
router.get('/favorites', requireAuth, userController.getFavorites);
router.post('/favorites/:restaurantId', requireAuth, userController.toggleFavorite);

// Admin user management endpoints
router.get('/', requireAuth, requireRole('admin'), userController.getUsers);
router.patch('/:id/role', requireAuth, requireRole('admin'), userController.updateUserRole);
router.patch('/:id/status', requireAuth, requireRole('admin'), userController.updateUserStatus);

module.exports = router;
