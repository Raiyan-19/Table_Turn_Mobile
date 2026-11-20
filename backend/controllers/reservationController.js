const crypto = require('crypto');
const Reservation = require('../models/Reservation');
const Table = require('../models/Table');
const Restaurant = require('../models/Restaurant');
const Notification = require('../models/Notification');

/**
 * Generate cryptographic booking reference: TT-2026-XXXXXX
 */
function generateBookingRef() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let ref = 'TT-2026-';
  const randomBytes = crypto.randomBytes(6);
  for (let i = 0; i < 6; i++) {
    ref += chars[randomBytes[i] % chars.length];
  }
  return ref;
}

/**
 * GET /api/reservations
 * Fetch user's reservations (for customer), or restaurant's reservations (for manager/admin).
 */
async function getReservations(req, res) {
  try {
    const filter = {};
    const { status, restaurantId } = req.query;

    if (req.user.role === 'customer') {
      filter.userId = req.user._id;
    } else if (req.user.role === 'manager') {
      if (req.user.managedRestaurantId) {
        filter.restaurantId = req.user.managedRestaurantId;
      }
    } else if (req.user.role === 'admin' && restaurantId) {
      filter.restaurantId = restaurantId;
    }

    if (status) {
      filter.status = status;
    }

    const reservations = await Reservation.find(filter).sort({ reservationDate: -1, createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: reservations.length,
      data: reservations.map((r) => r.toJSON()),
    });
  } catch (err) {
    console.error('[Reservation Error] getReservations:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch reservations.' });
  }
}

/**
 * GET /api/reservations/:id
 * Get single reservation by ID.
 */
async function getReservationById(req, res) {
  try {
    const reservation = await Reservation.findById(req.params.id);
    if (!reservation) {
      return res.status(404).json({ success: false, message: 'Reservation not found.' });
    }

    // Authorization: Owner, assigned Manager, or Admin
    if (req.user.role === 'customer' && reservation.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Access denied.' });
    }

    return res.status(200).json({
      success: true,
      data: reservation.toJSON(),
    });
  } catch (err) {
    console.error('[Reservation Error] getReservationById:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch reservation.' });
  }
}

/**
 * POST /api/reservations
 * Create a new table reservation with atomic double-booking prevention.
 */
async function createReservation(req, res) {
  try {
    const {
      restaurantId,
      tableId,
      reservationDate,
      timeSlot,
      guestCount,
      specialRequests,
    } = req.body;

    if (!restaurantId || !tableId || !reservationDate || !timeSlot) {
      return res.status(400).json({
        success: false,
        message: 'Restaurant, table, reservation date, and time slot are required.',
      });
    }

    const parsedDate = new Date(reservationDate);
    const startOfDay = new Date(parsedDate.setHours(0, 0, 0, 0));
    const endOfDay = new Date(parsedDate.setHours(23, 59, 59, 999));

    // Verify restaurant exists
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found.' });
    }

    // Verify table exists
    const table = await Table.findById(tableId);
    if (!table) {
      return res.status(404).json({ success: false, message: 'Table not found.' });
    }

    // Atomic Double-Booking Validation: Check if table is already booked for this slot
    const existingBooking = await Reservation.findOne({
      restaurantId,
      tableId,
      timeSlot,
      reservationDate: { $gte: startOfDay, $lte: endOfDay },
      status: { $in: ['pending', 'confirmed', 'checkedIn', 'seated'] },
    });

    if (existingBooking) {
      return res.status(409).json({
        success: false,
        message: `This table is already reserved for ${timeSlot} on this date. Please choose another time or table.`,
      });
    }

    const bookingRef = generateBookingRef();
    const timestamp = Date.now();
    // Cryptographically formatted QR string: REF:REST_ID:TABLE_ID:USER_ID:TIMESTAMP
    const qrSignature = `${bookingRef}:${restaurant._id}:${table._id}:${req.user._id}:${timestamp}`;

    const newReservation = new Reservation({
      bookingRef,
      userId: req.user._id,
      userName: req.user.name,
      userPhone: req.user.phone || '',
      restaurantId: restaurant._id,
      restaurantName: restaurant.name,
      restaurantAddress: restaurant.address,
      restaurantCoverPhoto: restaurant.coverPhoto,
      tableId: table._id,
      tableNumber: table.tableNumber,
      tableSection: table.section,
      reservationDate: new Date(reservationDate),
      timeSlot,
      guestCount: guestCount || 2,
      specialRequests: specialRequests || null,
      status: 'confirmed',
      qrCodeData: qrSignature,
    });

    await newReservation.save();

    // Trigger Notification for the user
    try {
      await Notification.create({
        userId: req.user._id,
        title: 'Reservation Confirmed',
        body: `Your table for ${guestCount || 2} at ${restaurant.name} is confirmed for ${timeSlot}.`,
        type: 'booking_confirmed',
        data: { bookingId: newReservation._id.toString() },
      });
    } catch (_) {}

    return res.status(201).json({
      success: true,
      message: 'Reservation created successfully.',
      data: newReservation.toJSON(),
    });
  } catch (err) {
    console.error('[Reservation Error] createReservation:', err);
    return res.status(500).json({ success: false, message: err.message || 'Failed to create reservation.' });
  }
}

/**
 * PATCH /api/reservations/:id/cancel
 * Cancel an existing reservation.
 */
async function cancelReservation(req, res) {
  try {
    const reservation = await Reservation.findById(req.params.id);
    if (!reservation) {
      return res.status(404).json({ success: false, message: 'Reservation not found.' });
    }

    // Ownership guard: only customer who booked, or manager/admin
    if (req.user.role === 'customer' && reservation.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Forbidden: You cannot cancel another diner’s booking.' });
    }

    if (reservation.status === 'completed' || reservation.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: `Cannot cancel a reservation that is already ${reservation.status}.`,
      });
    }

    reservation.status = 'cancelled';
    await reservation.save();

    // Notify user
    try {
      await Notification.create({
        userId: reservation.userId,
        title: 'Reservation Cancelled',
        body: `Your reservation at ${reservation.restaurantName} (${reservation.timeSlot}) was cancelled.`,
        type: 'booking_cancelled',
        data: { bookingId: reservation._id.toString() },
      });
    } catch (_) {}

    return res.status(200).json({
      success: true,
      message: 'Reservation cancelled successfully.',
      data: reservation.toJSON(),
    });
  } catch (err) {
    console.error('[Reservation Error] cancelReservation:', err);
    return res.status(500).json({ success: false, message: 'Failed to cancel reservation.' });
  }
}

/**
 * POST /api/reservations/verify-qr
 * Host Manager QR code verification & live check-in with cross-restaurant tenant isolation.
 */
async function verifyQrCode(req, res) {
  try {
    const { code } = req.body;
    if (!code || code.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'QR data or booking reference is required.' });
    }

    const cleanCode = code.trim().toUpperCase();
    const ref = cleanCode.split(':')[0];

    const reservation = await Reservation.findOne({
      $or: [
        { bookingRef: ref },
        { bookingRef: cleanCode },
        { qrCodeData: code.trim() },
      ],
    });

    if (!reservation) {
      return res.status(404).json({
        success: false,
        message: 'No active reservation matches that code. Please check and scan again.',
      });
    }

    // Tenant Isolation Check: Manager can ONLY verify reservations for their assigned restaurant
    if (req.user.role === 'manager') {
      const managerRestId = req.user.managedRestaurantId;
      if (managerRestId && reservation.restaurantId.toString() !== managerRestId) {
        return res.status(403).json({
          success: false,
          message: `Security Alert: This reservation is for "${reservation.restaurantName}". Cross-restaurant check-in is strictly forbidden.`,
        });
      }
    }

    // Status checks
    let statusNotice = null;
    if (reservation.status === 'checkedIn' || reservation.status === 'completed') {
      statusNotice = 'Notice: This guest has already been checked in.';
    } else if (reservation.status === 'cancelled') {
      statusNotice = 'Notice: This reservation was cancelled.';
    }

    return res.status(200).json({
      success: true,
      notice: statusNotice,
      data: reservation.toJSON(),
    });
  } catch (err) {
    console.error('[Reservation Error] verifyQrCode:', err);
    return res.status(500).json({ success: false, message: 'QR verification failed.' });
  }
}

/**
 * PATCH /api/reservations/:id/status
 * Host desk update reservation status (confirmed -> checkedIn -> seated -> completed).
 */
async function updateReservationStatus(req, res) {
  try {
    const { status } = req.body;
    const reservation = await Reservation.findById(req.params.id);
    if (!reservation) {
      return res.status(404).json({ success: false, message: 'Reservation not found.' });
    }

    reservation.status = status;
    await reservation.save();

    return res.status(200).json({
      success: true,
      message: `Reservation status updated to ${status}.`,
      data: reservation.toJSON(),
    });
  } catch (err) {
    console.error('[Reservation Error] updateReservationStatus:', err);
    return res.status(500).json({ success: false, message: 'Failed to update reservation status.' });
  }
}

module.exports = {
  getReservations,
  getReservationById,
  createReservation,
  cancelReservation,
  verifyQrCode,
  updateReservationStatus,
};
