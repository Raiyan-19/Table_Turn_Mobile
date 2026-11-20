const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

router.get('/', requireAuth, reservationController.getReservations);
router.get('/:id', requireAuth, reservationController.getReservationById);
router.post('/', requireAuth, reservationController.createReservation);
router.patch('/:id/cancel', requireAuth, reservationController.cancelReservation);
router.post(
  '/verify-qr',
  requireAuth,
  requireRole('manager', 'admin'),
  reservationController.verifyQrCode
);
router.patch(
  '/:id/status',
  requireAuth,
  requireRole('manager', 'admin'),
  reservationController.updateReservationStatus
);

module.exports = router;
