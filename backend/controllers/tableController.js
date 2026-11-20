const Table = require('../models/Table');
const Restaurant = require('../models/Restaurant');

/**
 * GET /api/restaurants/:restaurantId/tables
 * Get all tables for a specific restaurant.
 */
async function getTablesByRestaurant(req, res) {
  try {
    const { restaurantId } = req.params;
    const tables = await Table.find({ restaurantId }).sort({ tableNumber: 1 });

    return res.status(200).json({
      success: true,
      count: tables.length,
      data: tables.map((t) => t.toJSON()),
    });
  } catch (err) {
    console.error('[Table Error] getTablesByRestaurant:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch tables.' });
  }
}

/**
 * POST /api/restaurants/:restaurantId/tables
 * Create a new table in the restaurant (Admin or assigned Manager).
 */
async function createTable(req, res) {
  try {
    const { restaurantId } = req.params;
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found.' });
    }

    // Manager tenant permission check
    if (req.user.role === 'manager') {
      const isAssigned =
        req.user.managedRestaurantId === restaurantId ||
        (restaurant.managerId && restaurant.managerId.toString() === req.user._id.toString());
      if (!isAssigned) {
        return res.status(403).json({
          success: false,
          message: 'Forbidden: You can only add tables to your assigned restaurant.',
        });
      }
    }

    const newTable = new Table({
      ...req.body,
      restaurantId,
    });
    await newTable.save();

    return res.status(201).json({
      success: true,
      message: 'Table added successfully.',
      data: newTable.toJSON(),
    });
  } catch (err) {
    console.error('[Table Error] createTable:', err);
    return res.status(400).json({ success: false, message: err.message || 'Failed to create table.' });
  }
}

/**
 * PATCH /api/tables/:id/status
 * Update floor status (available / reserved / occupied).
 */
async function updateTableStatus(req, res) {
  try {
    const { status, nextAvailableTime } = req.body;
    const table = await Table.findById(req.params.id);
    if (!table) {
      return res.status(404).json({ success: false, message: 'Table not found.' });
    }

    if (status) table.status = status;
    if (nextAvailableTime !== undefined) table.nextAvailableTime = nextAvailableTime;
    await table.save();

    return res.status(200).json({
      success: true,
      message: 'Table status updated.',
      data: table.toJSON(),
    });
  } catch (err) {
    console.error('[Table Error] updateTableStatus:', err);
    return res.status(400).json({ success: false, message: 'Failed to update table status.' });
  }
}

/**
 * DELETE /api/tables/:id
 * Remove table from inventory.
 */
async function deleteTable(req, res) {
  try {
    const table = await Table.findByIdAndDelete(req.params.id);
    if (!table) {
      return res.status(404).json({ success: false, message: 'Table not found.' });
    }

    return res.status(200).json({
      success: true,
      message: 'Table removed successfully.',
    });
  } catch (err) {
    console.error('[Table Error] deleteTable:', err);
    return res.status(500).json({ success: false, message: 'Failed to delete table.' });
  }
}

module.exports = {
  getTablesByRestaurant,
  createTable,
  updateTableStatus,
  deleteTable,
};
