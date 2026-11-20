const Review = require('../models/Review');
const Restaurant = require('../models/Restaurant');

/**
 * GET /api/restaurants/:restaurantId/reviews
 * Fetch all customer reviews for a restaurant.
 */
async function getReviewsByRestaurant(req, res) {
  try {
    const { restaurantId } = req.params;
    const reviews = await Review.find({ restaurantId }).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: reviews.length,
      data: reviews.map((r) => r.toJSON()),
    });
  } catch (err) {
    console.error('[Review Error] getReviewsByRestaurant:', err);
    return res.status(500).json({ success: false, message: 'Failed to fetch reviews.' });
  }
}

/**
 * POST /api/restaurants/:restaurantId/reviews
 * Submit a customer dining review and update restaurant rating aggregates.
 */
async function createReview(req, res) {
  try {
    const { restaurantId } = req.params;
    const { rating, comment } = req.body;

    if (!rating || !comment) {
      return res.status(400).json({ success: false, message: 'Rating and comment are required.' });
    }

    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found.' });
    }

    const newReview = new Review({
      restaurantId,
      userId: req.user._id,
      userName: req.user.name,
      userAvatar: req.user.avatarUrl,
      rating: Number(rating),
      comment: comment.trim(),
    });
    await newReview.save();

    // Recalculate restaurant aggregate rating
    const allReviews = await Review.find({ restaurantId });
    const avgRating = allReviews.reduce((sum, r) => sum + r.rating, 0) / allReviews.length;

    restaurant.rating = Number(avgRating.toFixed(1));
    restaurant.reviewCount = allReviews.length;
    await restaurant.save();

    return res.status(201).json({
      success: true,
      message: 'Review posted successfully.',
      data: newReview.toJSON(),
    });
  } catch (err) {
    console.error('[Review Error] createReview:', err);
    return res.status(400).json({ success: false, message: 'Failed to submit review.' });
  }
}

module.exports = {
  getReviewsByRestaurant,
  createReview,
};
