const express = require('express');
const router = express.Router();
const restaurantController = require('../controllers/restaurantController');
const tableController = require('../controllers/tableController');
const menuController = require('../controllers/menuController');
const reviewController = require('../controllers/reviewController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

// Public restaurant endpoints
router.get('/', restaurantController.getRestaurants);
router.get('/:id', restaurantController.getRestaurantById);

// Nested endpoints for tables, menu, reviews
router.get('/:restaurantId/tables', tableController.getTablesByRestaurant);
router.post(
  '/:restaurantId/tables',
  requireAuth,
  requireRole('manager', 'admin'),
  tableController.createTable
);

router.get('/:restaurantId/menu', menuController.getMenuByRestaurant);
router.post(
  '/:restaurantId/menu',
  requireAuth,
  requireRole('manager', 'admin'),
  menuController.createMenuItem
);

router.get('/:restaurantId/reviews', reviewController.getReviewsByRestaurant);
router.post('/:restaurantId/reviews', requireAuth, reviewController.createReview);

// Admin / Manager restaurant management
router.post('/', requireAuth, requireRole('admin', 'manager'), restaurantController.createRestaurant);
router.put('/:id', requireAuth, requireRole('admin', 'manager'), restaurantController.updateRestaurant);
router.delete('/:id', requireAuth, requireRole('admin'), restaurantController.deleteRestaurant);

module.exports = router;
