const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Restaurant name is required'],
      trim: true,
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
    },
    division: {
      type: String,
      required: true,
      enum: [
        'dhaka',
        'chittagong',
        'sylhet',
        'rajshahi',
        'rangpur',
        'khulna',
        'barishal',
        'mymensingh',
      ],
      default: 'dhaka',
    },
    city: {
      type: String,
      required: true,
      default: 'Dhaka',
    },
    address: {
      type: String,
      required: true,
    },
    latitude: {
      type: Number,
      default: 23.8103,
    },
    longitude: {
      type: Number,
      default: 90.4125,
    },
    phone: {
      type: String,
      default: '',
    },
    email: {
      type: String,
      default: '',
    },
    photos: {
      type: [String],
      default: [],
    },
    coverPhoto: {
      type: String,
      required: true,
    },
    cuisineTypes: {
      type: [String],
      default: ['Continental'],
    },
    priceCategory: {
      type: String,
      enum: ['budget', 'moderate', 'premium', 'luxury'],
      default: 'moderate',
    },
    rating: {
      type: Number,
      default: 4.5,
      min: 0,
      max: 5,
    },
    reviewCount: {
      type: Number,
      default: 0,
    },
    openingHours: {
      type: String,
      default: '11:00 AM - 11:00 PM',
    },
    facilities: {
      type: [String],
      default: [],
    },
    isFeatured: {
      type: Boolean,
      default: false,
    },
    isOpenNow: {
      type: Boolean,
      default: true,
    },
    managerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform(doc, ret) {
        ret.id = ret._id.toString();
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

restaurantSchema.virtual('tables', {
  ref: 'Table',
  localField: '_id',
  foreignField: 'restaurantId',
});

module.exports = mongoose.model('Restaurant', restaurantSchema);
