require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Restaurant = require('../models/Restaurant');
const Table = require('../models/Table');
const MenuItem = require('../models/MenuItem');
const Review = require('../models/Review');
const Reservation = require('../models/Reservation');
const Notification = require('../models/Notification');

async function seedDatabase() {
  const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/tableturn';
  console.log(`[Seeder] Connecting to MongoDB: ${uri}`);
  await mongoose.connect(uri);

  console.log('[Seeder] Cleaning existing test/seed collections...');
  await Promise.all([
    User.deleteMany({}),
    Restaurant.deleteMany({}),
    Table.deleteMany({}),
    MenuItem.deleteMany({}),
    Review.deleteMany({}),
    Reservation.deleteMany({}),
    Notification.deleteMany({}),
  ]);

  console.log('[Seeder] Creating foundational users...');

  // 1. Authoritative Admin
  const adminUser = new User({
    name: 'System Administrator',
    email: 'admin@tableturn.app',
    phone: '+8801900000000',
    password: 'adminpassword123',
    role: 'admin',
    isEmailVerified: true,
    isPhoneVerified: true,
  });
  await adminUser.save();

  // 2. Default Customer
  const customerUser = new User({
    name: 'Sultan Md. Raiyan',
    email: 'raiyan@tableturn.app',
    phone: '+8801571284636',
    password: 'customerpassword123',
    role: 'customer',
    isEmailVerified: true,
    isPhoneVerified: true,
  });
  await customerUser.save();

  // 3. Additional Test Diner
  const dinerUser = new User({
    name: 'Tasmia Nahar',
    email: 'tasmia@tableturn.app',
    phone: '+8801711998877',
    password: 'dinerpassword123',
    role: 'customer',
    isEmailVerified: true,
    isPhoneVerified: true,
  });
  await dinerUser.save();

  console.log('[Seeder] Seeding nationwide partner venues across Bangladesh...');

  // Restaurant 1: The Forest Lounge (Gulshan-2, Dhaka)
  const rest1 = await Restaurant.create({
    name: 'The Forest Lounge',
    description:
      'Upscale fine dining surrounded by lush botanical aesthetics in Gulshan-2. Specializing in dry-aged prime steaks, wood-fired artisanal pizzas, and continental gourmet gastronomy.',
    division: 'dhaka',
    city: 'Dhaka',
    address: 'House 14, Road 103, Gulshan-2, Dhaka 1212',
    latitude: 23.7925,
    longitude: 90.4172,
    phone: '+8801711223344',
    email: 'reservations@theforestlounge.com',
    photos: [
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
    ],
    coverPhoto:
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    cuisineTypes: ['Continental', 'Steakhouse', 'Italian'],
    priceCategory: 'premium',
    rating: 4.8,
    reviewCount: 342,
    openingHours: '12:00 PM - 11:30 PM',
    facilities: ['Valet Parking', 'WiFi', 'VIP Booths', 'Card Payment', 'Live Acoustic Music'],
    isFeatured: true,
    isOpenNow: true,
  });

  // Assign Manager to The Forest Lounge
  const managerUser = new User({
    name: 'Chef Tanvir Ahmed',
    email: 'manager@theforestlounge.com',
    phone: '+8801711223344',
    password: 'managerpassword123',
    role: 'manager',
    managedRestaurantId: rest1._id.toString(),
    isEmailVerified: true,
    isPhoneVerified: true,
  });
  await managerUser.save();
  rest1.managerId = managerUser._id;
  await rest1.save();

  // Restaurant 2: Skyline Terrace Dining (Banani, Dhaka)
  const rest2 = await Restaurant.create({
    name: 'Skyline Terrace Dining',
    description:
      'Panoramic rooftop skyline view of Banani lake and diplomatic enclave. Featuring Pan-Asian, Japanese sushi bar, and premium signature mocktails.',
    division: 'dhaka',
    city: 'Dhaka',
    address: 'Tower 71, Level 18, Road 11, Banani, Dhaka',
    latitude: 23.7937,
    longitude: 90.4043,
    phone: '+8801822334455',
    email: 'book@skylineterrace.bd',
    photos: [
      'https://images.unsplash.com/photo-1578474846511-04ba529f0b88?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
    ],
    coverPhoto:
      'https://images.unsplash.com/photo-1578474846511-04ba529f0b88?auto=format&fit=crop&w=800&q=80',
    cuisineTypes: ['Pan-Asian', 'Japanese', 'Rooftop Lounge'],
    priceCategory: 'luxury',
    rating: 4.9,
    reviewCount: 489,
    openingHours: '04:00 PM - 12:30 AM',
    facilities: ['Rooftop View', 'Lake View', 'Full Air Conditioning', 'Elevator Access', 'Private Rooms'],
    isFeatured: true,
    isOpenNow: true,
  });

  // Restaurant 3: Mezbani Heritage (Chittagong)
  const rest3 = await Restaurant.create({
    name: 'Mezbani Heritage GEC',
    description:
      'Traditional authentic Chittagonian Mezbani beef cooked in slow clay cauldrons with pure mustard oil and secret spices.',
    division: 'chittagong',
    city: 'Chittagong',
    address: 'Plot 4, GEC Circle, CDA Avenue, Chattogram 4000',
    latitude: 22.3569,
    longitude: 91.8215,
    phone: '+8801933445566',
    email: 'chattogram@mezbaniheritage.com',
    photos: [
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
    ],
    coverPhoto:
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
    cuisineTypes: ['Chittagonian', 'Traditional Bengali', 'Mezbani'],
    priceCategory: 'budget',
    rating: 4.7,
    reviewCount: 512,
    openingHours: '11:00 AM - 11:00 PM',
    facilities: ['Family Dining', 'Traditional Dastarkhān', 'Takeaway Counter'],
    isFeatured: true,
    isOpenNow: true,
  });

  // Restaurant 4: Seven Layer Green Garden (Sylhet)
  const rest4 = await Restaurant.create({
    name: 'Seven Layer Green Garden',
    description:
      'Nestled amidst aromatic tea garden hills of Sylhet. Famous for smoked Shatkora beef curry, garden-fresh roasted chicken, and organic green tea.',
    division: 'sylhet',
    city: 'Sylhet',
    address: 'Airport Road, Ambarkhana, Sylhet 3100',
    latitude: 24.8949,
    longitude: 91.8687,
    phone: '+8801755667788',
    email: 'info@sevenlayersylhet.com',
    photos: [
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    ],
    coverPhoto:
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    cuisineTypes: ['Sylheti Shatkora', 'BBQ', 'Bengali Fusion'],
    priceCategory: 'moderate',
    rating: 4.6,
    reviewCount: 278,
    openingHours: '10:00 AM - 11:00 PM',
    facilities: ['Tea Garden View', 'Gazebos', 'Kids Playground', 'Outdoor Grill'],
    isFeatured: false,
    isOpenNow: true,
  });

  // Restaurant 5: Sundarban Coastal Bay (Khulna)
  const rest5 = await Restaurant.create({
    name: 'Sundarban Coastal Bay',
    description:
      'Fresh coastal seafood, jumbo tiger prawns, crab masala, and signature Khulna duck curry cooked in authentic mustard oil.',
    division: 'khulna',
    city: 'Khulna',
    address: 'KDA Avenue, Royal More, Khulna 9100',
    latitude: 22.8456,
    longitude: 89.5403,
    phone: '+8801744556677',
    email: 'info@sundarbancoastal.com',
    photos: [
      'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae?auto=format&fit=crop&w=800&q=80',
    ],
    coverPhoto:
      'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae?auto=format&fit=crop&w=800&q=80',
    cuisineTypes: ['Seafood', 'Coastal Bengali', 'Chui Jhal'],
    priceCategory: 'moderate',
    rating: 4.6,
    reviewCount: 220,
    openingHours: '12:00 PM - 11:00 PM',
    facilities: ['Seafood Live Display', 'Air Conditioned', 'Card Accepted'],
    isFeatured: false,
    isOpenNow: true,
  });

  // Set user favorites
  customerUser.favoriteRestaurantIds = [rest1._id.toString(), rest2._id.toString()];
  await customerUser.save();

  console.log('[Seeder] Seeding dining tables...');

  // Tables for The Forest Lounge
  const tbl1 = await Table.create({
    restaurantId: rest1._id,
    tableNumber: 'Table 01',
    section: 'window',
    capacity: 2,
    status: 'available',
    minimumSpend: 1500,
    features: ['Gulshan Avenue View', 'Intimate Candlelight', 'Quiet Corner'],
  });

  const tbl2 = await Table.create({
    restaurantId: rest1._id,
    tableNumber: 'Table 04',
    section: 'indoor',
    capacity: 4,
    status: 'available',
    minimumSpend: 2500,
    features: ['Near Botanical Fountain', 'Plush Sofa Seating'],
  });

  const tbl3 = await Table.create({
    restaurantId: rest1._id,
    tableNumber: 'Table 08 – VIP',
    section: 'vip',
    capacity: 6,
    status: 'available',
    minimumSpend: 5000,
    features: ['Private Curtain Partition', 'Dedicated Butler Service', 'Champagne Cooler'],
  });

  const tbl4 = await Table.create({
    restaurantId: rest1._id,
    tableNumber: 'Table 12',
    section: 'outdoor',
    capacity: 4,
    status: 'reserved',
    nextAvailableTime: '08:30 PM',
    minimumSpend: 3000,
    features: ['Patio Lanterns', 'Open Air Greenery'],
  });

  const tbl5 = await Table.create({
    restaurantId: rest1._id,
    tableNumber: 'Table 15',
    section: 'indoor',
    capacity: 8,
    status: 'available',
    minimumSpend: 6000,
    features: ['Large Family Table', 'Lazy Susan Turning Tray'],
  });

  // Tables for Skyline Terrace
  const tbl6 = await Table.create({
    restaurantId: rest2._id,
    tableNumber: 'Rooftop T-01',
    section: 'rooftop',
    capacity: 2,
    status: 'available',
    minimumSpend: 3000,
    features: ['Edge-of-Skyline Lake View', 'Glass Railing', 'High Stool'],
  });

  const tbl7 = await Table.create({
    restaurantId: rest2._id,
    tableNumber: 'VIP Lounge A',
    section: 'vip',
    capacity: 10,
    status: 'reserved',
    nextAvailableTime: '09:00 PM',
    minimumSpend: 10000,
    features: ['Private Suite', 'City Horizon View', 'Surround Sound'],
  });

  console.log('[Seeder] Seeding menu items...');

  await MenuItem.create([
    {
      restaurantId: rest1._id,
      name: 'USDA Prime Ribeye Steak (300g)',
      description:
        'Charbroiled Australian grain-fed ribeye, truffle mashed potatoes, grilled asparagus, and wild mushroom jus.',
      category: 'Chef Specials',
      price: 3450,
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=80',
      isAvailable: true,
      rating: 4.9,
    },
    {
      restaurantId: rest1._id,
      name: 'Wood-Fired Burrata Margherita',
      description:
        'Hand-stretched sourdough pizza, San Marzano tomato reduction, buffalo mozzarella, fresh creamy burrata crown, and organic basil.',
      category: 'Main Course',
      price: 1850,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=600&q=80',
      isAvailable: true,
      isVegetarian: true,
      rating: 4.8,
    },
    {
      restaurantId: rest1._id,
      name: 'Crispy Calamari Fritti',
      description:
        'Golden seasoned baby squid rings, spicy smoked paprika aioli, and charred Meyer lemon wedges.',
      category: 'Starters',
      price: 980,
      imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=600&q=80',
      isAvailable: true,
      rating: 4.7,
    },
    {
      restaurantId: rest1._id,
      name: 'Belgian Molten Lava Cake',
      description:
        '70% dark Belgian chocolate warm souffle, flowing molten center, Madagascar bourbon vanilla gelato.',
      category: 'Desserts',
      price: 750,
      imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=600&q=80',
      isAvailable: true,
      isVegetarian: true,
      rating: 4.9,
    },
    {
      restaurantId: rest1._id,
      name: 'Botanical Passion Mint Cooler',
      description:
        'Pressed passion fruit pulp, crushed garden mint, Sicilian lime juice, sparkling soda water, and kaffir leaf essence.',
      category: 'Beverages',
      price: 490,
      imageUrl: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=600&q=80',
      isAvailable: true,
      isVegetarian: true,
      rating: 4.8,
    },
  ]);

  console.log('[Seeder] Seeding guest reviews...');

  await Review.create([
    {
      restaurantId: rest1._id,
      userId: dinerUser._id,
      userName: dinerUser.name,
      rating: 5,
      comment:
        'Exceptional ambiance! The table by the window had a magnificent view and the ribeye was cooked to absolute medium-rare perfection. QR check-in took 5 seconds at the front desk.',
    },
    {
      restaurantId: rest1._id,
      userId: customerUser._id,
      userName: customerUser.name,
      rating: 4.5,
      comment:
        'Very seamless reservation process on TableTurn. We reserved Table 08 for our anniversary; the staff had flowers and candlelight ready as requested in special requests.',
    },
  ]);

  console.log('[Seeder] Seeding initial confirmed reservations...');

  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);

  await Reservation.create({
    bookingRef: 'TT-2026-9812',
    userId: customerUser._id,
    userName: customerUser.name,
    userPhone: customerUser.phone,
    restaurantId: rest1._id,
    restaurantName: rest1.name,
    restaurantAddress: rest1.address,
    restaurantCoverPhoto: rest1.coverPhoto,
    tableId: tbl1._id,
    tableNumber: tbl1.tableNumber,
    tableSection: 'Window View',
    reservationDate: tomorrow,
    timeSlot: '07:30 PM',
    guestCount: 2,
    specialRequests: 'Quiet window corner for dinner date.',
    status: 'confirmed',
    qrCodeData: `TT-2026-9812:${rest1._id}:${tbl1._id}:${customerUser._id}:${Date.now()}`,
  });

  const lastWeek = new Date();
  lastWeek.setDate(lastWeek.getDate() - 7);

  await Reservation.create({
    bookingRef: 'TT-2026-8401',
    userId: customerUser._id,
    userName: customerUser.name,
    userPhone: customerUser.phone,
    restaurantId: rest2._id,
    restaurantName: rest2.name,
    restaurantAddress: rest2.address,
    restaurantCoverPhoto: rest2.coverPhoto,
    tableId: tbl6._id,
    tableNumber: tbl6.tableNumber,
    tableSection: 'Rooftop Terrace',
    reservationDate: lastWeek,
    timeSlot: '08:00 PM',
    guestCount: 2,
    specialRequests: 'Sunset view table.',
    status: 'completed',
    qrCodeData: `TT-2026-8401:${rest2._id}:${tbl6._id}:${customerUser._id}:${Date.now()}`,
  });

  console.log('[Seeder] Seeding notifications...');

  await Notification.create([
    {
      userId: customerUser._id,
      title: 'Reservation Confirmed',
      body: 'Your table for 2 at The Forest Lounge (Gulshan-2) is confirmed for tomorrow at 07:30 PM.',
      type: 'booking_confirmed',
    },
    {
      userId: customerUser._id,
      title: 'Upcoming Dining Reminder',
      body: 'Reminder: Have your digital QR pass ready upon arrival at The Forest Lounge.',
      type: 'booking_reminder',
    },
  ]);

  console.log('========================================================');
  console.log('  TABLETURN SEED COMPLETE:');
  console.log('  - Admin:    admin@tableturn.app (Password: adminpassword123)');
  console.log('  - Manager:  manager@theforestlounge.com (Password: managerpassword123)');
  console.log('  - Customer: raiyan@tableturn.app (Password: customerpassword123)');
  console.log('  - Venues:   5 seeded (Dhaka, Banani, Chittagong, Sylhet, Khulna)');
  console.log('  - Tables:   7 seeded with live status');
  console.log('  - Menus:    Categorized dishes & drinks');
  console.log('  - Bookings: Active & past reservations with verifiable QR');
  console.log('========================================================');

  await mongoose.connection.close();
}

if (require.main === module) {
  seedDatabase().catch((err) => {
    console.error('Seeder failed:', err);
    process.exit(1);
  });
}

module.exports = seedDatabase;
