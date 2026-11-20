const MenuItem = require('../models/MenuItem');

/**
 * GET /api/restaurants/:restaurantId/menu
 * Get full categorized menu for a restaurant.
 */
async function getMenuByRestaurant(req, res) {
  try {
    const { restaurantId } = req.params;
    const menuItems = await MenuItem.find({ restaurantId }).sort({ category: 1, price: 1 });

    return res.status(200).json({
      success: true,
      count: menuItems.length,
      data: menuItems.map((m) => m.toJSON()),
    });
  } catch (err) {
    console.error('[Menu Error] getMenuByRestaurant:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch menu items.' });
  }
}

/**
 * POST /api/restaurants/:restaurantId/menu
 * Add a new dish/beverage to the restaurant menu.
 */
async function createMenuItem(req, res) {
  try {
    const { restaurantId } = req.params;
    const newItem = new MenuItem({
      ...req.body,
      restaurantId,
    });
    await newItem.save();

    return res.status(201).json({
      success: true,
      message: 'Menu item created successfully.',
      data: newItem.toJSON(),
    });
  } catch (err) {
    console.error('[Menu Error] createMenuItem:', err);
    return res.status(400).json({ success: false, message: 'Failed to create menu item.' });
  }
}

/**
 * PUT /api/menu/:id
 * Update menu item details or availability.
 */
async function updateMenuItem(req, res) {
  try {
    const item = await MenuItem.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!item) {
      return res.status(404).json({ success: false, message: 'Menu item not found.' });
    }

    return res.status(200).json({
      success: true,
      message: 'Menu item updated.',
      data: item.toJSON(),
    });
  } catch (err) {
    console.error('[Menu Error] updateMenuItem:', err);
    return res.status(400).json({ success: false, message: 'Failed to update menu item.' });
  }
}

/**
 * DELETE /api/menu/:id
 * Remove item from restaurant menu.
 */
async function deleteMenuItem(req, res) {
  try {
    const item = await MenuItem.findByIdAndDelete(req.params.id);
    if (!item) {
      return res.status(404).json({ success: false, message: 'Menu item not found.' });
    }

    return res.status(200).json({
      success: true,
      message: 'Menu item deleted.',
    });
  } catch (err) {
    console.error('[Menu Error] deleteMenuItem:', err);
    return res.status(500).json({ success: false, message: 'Failed to delete menu item.' });
  }
}

module.exports = {
  getMenuByRestaurant,
  createMenuItem,
  updateMenuItem,
  deleteMenuItem,
};
