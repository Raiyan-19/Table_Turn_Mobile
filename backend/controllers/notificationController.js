const Notification = require('../models/Notification');

/**
 * GET /api/notifications
 * Fetch notifications for authenticated user.
 */
async function getNotifications(req, res) {
  try {
    const notifications = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: notifications.length,
      data: notifications.map((n) => n.toJSON()),
    });
  } catch (err) {
    console.error('[Notification Error] getNotifications:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch notifications.' });
  }
}

/**
 * PATCH /api/notifications/:id/read
 * Mark a notification as read.
 */
async function markAsRead(req, res) {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { isRead: true },
      { new: true }
    );
    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found.' });
    }

    return res.status(200).json({
      success: true,
      data: notification.toJSON(),
    });
  } catch (err) {
    console.error('[Notification Error] markAsRead:', err);
    return res.status(400).json({ success: false, message: 'Failed to update notification.' });
  }
}

module.exports = {
  getNotifications,
  markAsRead,
};
