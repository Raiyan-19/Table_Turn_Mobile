const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menuController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

router.put('/:id', requireAuth, requireRole('manager', 'admin'), menuController.updateMenuItem);
router.delete('/:id', requireAuth, requireRole('manager', 'admin'), menuController.deleteMenuItem);

module.exports = router;
