const User = require('../models/User');
const Restaurant = require('../models/Restaurant');

/**
 * GET /api/users/favorites
 * Retrieve list of user's favorited restaurants.
 */
async function getFavorites(req, res) {
  try {
    const user = await User.findById(req.user._id);
    const favoriteIds = user.favoriteRestaurantIds || [];
    const restaurants = await Restaurant.find({ _id: { $in: favoriteIds } });

    return res.status(200).json({
      success: true,
      data: restaurants.map((r) => r.toJSON()),
    });
  } catch (err) {
    console.error('[User Error] getFavorites:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch favorites.' });
  }
}

/**
 * POST /api/users/favorites/:restaurantId
 * Toggle restaurant favorite status for the authenticated user.
 */
async function toggleFavorite(req, res) {
  try {
    const { restaurantId } = req.params;
    const user = await User.findById(req.user._id);

    const index = user.favoriteRestaurantIds.indexOf(restaurantId);
    let isFavorite = false;

    if (index > -1) {
      user.favoriteRestaurantIds.splice(index, 1);
      isFavorite = false;
    } else {
      user.favoriteRestaurantIds.push(restaurantId);
      isFavorite = true;
    }

    await user.save();

    return res.status(200).json({
      success: true,
      isFavorite,
      favoriteRestaurantIds: user.favoriteRestaurantIds,
      message: isFavorite ? 'Added to favorites.' : 'Removed from favorites.',
    });
  } catch (err) {
    console.error('[User Error] toggleFavorite:', err);
    return res.status(500).json({ success: false, message: 'Failed to toggle favorite.' });
  }
}

/**
 * GET /api/users
 * Admin endpoint: List platform users.
 */
async function getUsers(req, res) {
  try {
    const { role } = req.query;
    const filter = {};
    if (role) filter.role = role;

    const users = await User.find(filter).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: users.length,
      data: users.map((u) => u.toJSON()),
    });
  } catch (err) {
    console.error('[User Error] getUsers:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch users.' });
  }
}

/**
 * PATCH /api/users/:id/role
 * Admin endpoint: Assign role and optional managed restaurant.
 */
async function updateUserRole(req, res) {
  try {
    const { role, managedRestaurantId } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    if (role) user.role = role;
    if (managedRestaurantId !== undefined) user.managedRestaurantId = managedRestaurantId;
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'User role updated.',
      data: user.toJSON(),
    });
  } catch (err) {
    console.error('[User Error] updateUserRole:', err);
    return res.status(400).json({ success: false, message: 'Failed to update user role.' });
  }
}

/**
 * PATCH /api/users/:id/status
 * Admin endpoint: Activate or suspend user account.
 */
async function updateUserStatus(req, res) {
  try {
    const { isActive } = req.body;
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    user.isActive = Boolean(isActive);
    await user.save();

    return res.status(200).json({
      success: true,
      message: `User account ${user.isActive ? 'activated' : 'suspended'}.`,
      data: user.toJSON(),
    });
  } catch (err) {
    console.error('[User Error] updateUserStatus:', err);
    return res.status(400).json({ success: false, message: 'Failed to update user status.' });
  }
}

module.exports = {
  getFavorites,
  toggleFavorite,
  getUsers,
  updateUserRole,
  updateUserStatus,
};
