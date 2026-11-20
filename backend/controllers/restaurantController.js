const Restaurant = require('../models/Restaurant');
const Table = require('../models/Table');

/**
 * GET /api/restaurants
 * List restaurants with optional division, cuisine, priceCategory, and search filtering.
 */
async function getRestaurants(req, res) {
  try {
    const { division, cuisine, price, search } = req.query;
    const filter = {};

    if (division && division.toLowerCase() !== 'all') {
      filter.division = division.toLowerCase();
    }

    if (cuisine && cuisine.toLowerCase() !== 'all') {
      filter.cuisineTypes = { $regex: cuisine, $options: 'i' };
    }

    if (price && price.toLowerCase() !== 'all') {
      filter.priceCategory = price.toLowerCase();
    }

    if (search && search.trim().length > 0) {
      const q = search.trim();
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { city: { $regex: q, $options: 'i' } },
        { address: { $regex: q, $options: 'i' } },
        { cuisineTypes: { $regex: q, $options: 'i' } },
      ];
    }

    const restaurants = await Restaurant.find(filter).sort({ isFeatured: -1, rating: -1 });

    // Calculate live available tables count for each restaurant
    const results = await Promise.all(
      restaurants.map(async (rest) => {
        const availableTablesCount = await Table.countDocuments({
          restaurantId: rest._id,
          status: 'available',
        });
        const restJson = rest.toJSON();
        restJson.availableTablesCount = availableTablesCount;
        return restJson;
      })
    );

    return res.status(200).json({
      success: true,
      count: results.length,
      data: results,
    });
  } catch (err) {
    console.error('[Restaurant Error] getRestaurants:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch restaurants.' });
  }
}

/**
 * GET /api/restaurants/:id
 * Retrieve single restaurant by ID with its live tables and menu items.
 */
async function getRestaurantById(req, res) {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found.' });
    }

    const tables = await Table.find({ restaurantId: restaurant._id });
    const availableTablesCount = tables.filter((t) => t.status === 'available').length;

    const restJson = restaurant.toJSON();
    restJson.availableTablesCount = availableTablesCount;
    restJson.tables = tables.map((t) => t.toJSON());

    return res.status(200).json({
      success: true,
      data: restJson,
    });
  } catch (err) {
    console.error('[Restaurant Error] getRestaurantById:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch restaurant details.' });
  }
}

/**
 * POST /api/restaurants
 * Create a new partner venue (Admin or Manager).
 */
async function createRestaurant(req, res) {
  try {
    const newRestaurant = new Restaurant(req.body);
    if (req.user && req.user.role === 'manager' && !newRestaurant.managerId) {
      newRestaurant.managerId = req.user._id;
    }
    await newRestaurant.save();

    return res.status(201).json({
      success: true,
      message: 'Restaurant created successfully.',
      data: newRestaurant.toJSON(),
    });
  } catch (err) {
    console.error('[Restaurant Error] createRestaurant:', err);
    return res.status(400).json({ success: false, message: err.message || 'Failed to create restaurant.' });
  }
}

/**
 * PUT /api/restaurants/:id
 * Update restaurant information.
 */
async function updateRestaurant(req, res) {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found.' });
    }

    // Tenancy guard: Managers can only update their assigned restaurant
    if (req.user.role === 'manager') {
      const isAssigned =
        req.user.managedRestaurantId === restaurant._id.toString() ||
        (restaurant.managerId && restaurant.managerId.toString() === req.user._id.toString());
      if (!isAssigned) {
        return res.status(403).json({
          success: false,
          message: 'Access forbidden: You can only manage your assigned restaurant.',
        });
      }
    }

    Object.assign(restaurant, req.body);
    await restaurant.save();

    return res.status(200).json({
      success: true,
      message: 'Restaurant updated successfully.',
      data: restaurant.toJSON(),
    });
  } catch (err) {
    console.error('[Restaurant Error] updateRestaurant:', err);
    return res.status(400).json({ success: false, message: 'Failed to update restaurant.' });
  }
}

/**
 * DELETE /api/restaurants/:id
 * Delete restaurant (Admin only).
 */
async function deleteRestaurant(req, res) {
  try {
    const restaurant = await Restaurant.findByIdAndDelete(req.params.id);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found.' });
    }

    // Clean up associated tables
    await Table.deleteMany({ restaurantId: req.params.id });

    return res.status(200).json({
      success: true,
      message: 'Restaurant deleted successfully.',
    });
  } catch (err) {
    console.error('[Restaurant Error] deleteRestaurant:', err);
    return res.status(500).json({ success: false, message: 'Failed to delete restaurant.' });
  }
}

module.exports = {
  getRestaurants,
  getRestaurantById,
  createRestaurant,
  updateRestaurant,
  deleteRestaurant,
};
