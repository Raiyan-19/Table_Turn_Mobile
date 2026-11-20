const express = require('express');
const router = express.Router();
const tableController = require('../controllers/tableController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

router.patch('/:id/status', requireAuth, requireRole('manager', 'admin'), tableController.updateTableStatus);
router.delete('/:id', requireAuth, requireRole('manager', 'admin'), tableController.deleteTable);

module.exports = router;
