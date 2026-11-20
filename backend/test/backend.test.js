/**
 * Comprehensive Backend Integration Test Suite for TableTurn REST API
 */
const mongoose = require('mongoose');
const request = require('http');

const PORT = 5002;
process.env.PORT = PORT;
process.env.NODE_ENV = 'test';
process.env.MONGO_URI = 'mongodb://127.0.0.1:27017/tableturn';
process.env.ADMIN_EMAIL = 'admin@tableturn.app';

const app = require('../server');
const seedDatabase = require('../seed/seeder');

function makeRequest(options, postData) {
  return new Promise((resolve, reject) => {
    const req = request.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });
    req.on('error', reject);
    if (postData) {
      req.write(JSON.stringify(postData));
    }
    req.end();
  });
}

async function runTests() {
  console.log('=== Starting Phase 3 Comprehensive Backend Test Suite ===');
  let server;
  try {
    // 1. Seed fresh test data
    await seedDatabase();

    await mongoose.connect(process.env.MONGO_URI);
    server = app.listen(PORT);
    console.log(`Backend test server running on port ${PORT}`);

    // Test 1: Health Check
    console.log('1. Health Check Endpoint...');
    const health = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: '/api/health',
      method: 'GET',
    });
    console.assert(health.status === 200, `Expected 200, got ${health.status}`);
    console.assert(health.data.status === 'healthy', 'Expected status: healthy');
    console.log('   ✓ Health check passed.');

    // Test 2: Restaurants List
    console.log('2. GET /api/restaurants...');
    const restRes = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: '/api/restaurants?division=dhaka',
      method: 'GET',
    });
    console.assert(restRes.status === 200, 'Expected 200');
    console.assert(restRes.data.data.length >= 2, 'Expected at least 2 Dhaka restaurants');
    const firstRest = restRes.data.data.find((r) => r.name.includes('Forest Lounge')) || restRes.data.data[0];
    console.assert(firstRest.availableTablesCount !== undefined, 'Expected availableTablesCount');
    console.log(`   ✓ Selected ${firstRest.name} with live tables.`);

    // Test 3: Tables List
    console.log('3. GET /api/restaurants/:id/tables...');
    const tableRes = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: `/api/restaurants/${firstRest.id}/tables`,
      method: 'GET',
    });
    console.assert(tableRes.status === 200, 'Expected 200');
    console.assert(tableRes.data.data.length > 0, 'Expected tables');
    const availableTable = tableRes.data.data.find((t) => t.status === 'available');
    console.assert(availableTable !== undefined, 'Expected at least one available table');
    console.log(`   ✓ Retrieved ${tableRes.data.data.length} tables for ${firstRest.name}.`);

    // Test 4: Customer Authentication
    console.log('4. Customer Sign In...');
    const custAuth = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'raiyan@tableturn.app',
        password: 'customerpassword123',
      }
    );
    console.assert(custAuth.status === 200, 'Expected 200');
    const customerToken = custAuth.data.token;
    console.log('   ✓ Customer logged in with JWT token.');

    // Test 5: Create Reservation
    console.log('5. POST /api/reservations (Valid Booking)...');
    const bookingDate = new Date();
    bookingDate.setDate(bookingDate.getDate() + 3);

    const bookingRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/reservations',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${customerToken}`,
        },
      },
      {
        restaurantId: firstRest.id,
        tableId: availableTable.id,
        reservationDate: bookingDate.toISOString(),
        timeSlot: '08:00 PM',
        guestCount: 2,
        specialRequests: 'Candlelight setup for anniversary.',
      }
    );
    console.assert(bookingRes.status === 201, `Expected 201, got ${bookingRes.status}`);
    const createdBooking = bookingRes.data.data;
    console.assert(createdBooking.bookingRef.startsWith('TT-2026-'), 'Expected TT-2026- prefix');
    console.assert(createdBooking.status === 'confirmed', 'Expected confirmed status');
    console.log(`   ✓ Reservation confirmed: Ref ${createdBooking.bookingRef}`);

    // Test 6: Double Booking Prevention (Race Condition / Overlap Check)
    console.log('6. POST /api/reservations (Double Booking Prevention)...');
    const doubleRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/reservations',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${customerToken}`,
        },
      },
      {
        restaurantId: firstRest.id,
        tableId: availableTable.id,
        reservationDate: bookingDate.toISOString(),
        timeSlot: '08:00 PM', // Same table, date, and slot
        guestCount: 4,
      }
    );
    console.assert(doubleRes.status === 409, `Expected 409 Conflict, got ${doubleRes.status}`);
    console.assert(doubleRes.data.success === false, 'Expected success: false');
    console.log('   ✓ Double booking strictly rejected with 409 Conflict.');

    // Test 7: Manager Login
    console.log('7. Manager Sign In...');
    const mgrAuth = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'manager@theforestlounge.com',
        password: 'managerpassword123',
      }
    );
    console.assert(mgrAuth.status === 200, 'Expected 200');
    const managerToken = mgrAuth.data.token;
    console.log('   ✓ Manager signed in with role manager.');

    // Test 8: Manager QR Code Verification
    console.log('8. POST /api/reservations/verify-qr (Manager Host Scan)...');
    const verifyRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/reservations/verify-qr',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${managerToken}`,
        },
      },
      {
        code: createdBooking.qrCodeData,
      }
    );
    console.assert(verifyRes.status === 200, `Expected 200, got ${verifyRes.status}`);
    console.assert(verifyRes.data.data.bookingRef === createdBooking.bookingRef, 'Expected matching ref');
    console.log(`   ✓ Manager successfully verified guest QR pass (${createdBooking.bookingRef}).`);

    // Test 9: Manager Tenant Isolation Check
    console.log('9. Manager Tenant Isolation Check...');
    // Try to verify booking from Skyline Terrace using Forest Lounge manager
    const skylineBooking = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/reservations/verify-qr',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${managerToken}`,
        },
      },
      {
        code: 'TT-2026-8401', // Belongs to Skyline Terrace
      }
    );
    console.assert(skylineBooking.status === 403, `Expected 403 Forbidden, got ${skylineBooking.status}`);
    console.log('   ✓ Cross-restaurant verification blocked by tenant isolation (403).');

    // Test 10: Customer Booking Cancellation
    console.log('10. PATCH /api/reservations/:id/cancel...');
    const cancelRes = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: `/api/reservations/${createdBooking.id}/cancel`,
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${customerToken}`,
      },
    });
    console.assert(cancelRes.status === 200, 'Expected 200');
    console.assert(cancelRes.data.data.status === 'cancelled', 'Expected cancelled status');
    console.log('   ✓ Reservation successfully cancelled by owner.');

    // Test 11: Admin Login & User Oversight
    console.log('11. Admin Login & User Oversight...');
    const adminAuth = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'admin@tableturn.app',
        password: 'adminpassword123',
      }
    );
    console.assert(adminAuth.status === 200, 'Expected 200');
    const adminToken = adminAuth.data.token;

    const userList = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: '/api/users',
      method: 'GET',
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    console.assert(userList.status === 200, 'Expected 200');
    console.assert(userList.data.data.length >= 3, 'Expected at least 3 users');
    console.log(`   ✓ Admin retrieved platform users list (${userList.data.data.length} registered).`);

    // Test 12: Menu Items & Reviews
    console.log('12. Menu & Review Aggregation...');
    const menuRes = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: `/api/restaurants/${firstRest.id}/menu`,
      method: 'GET',
    });
    console.assert(menuRes.status === 200, 'Expected 200');
    console.assert(menuRes.data.data.length >= 5, 'Expected 5 dishes/beverages');

    const revPost = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: `/api/restaurants/${firstRest.id}/reviews`,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${customerToken}`,
        },
      },
      {
        rating: 5,
        comment: 'Outstanding ribeye and incredible atmosphere!',
      }
    );
    console.assert(revPost.status === 201, 'Expected 201');
    console.log('   ✓ Menu items retrieved and customer review posted.');

    console.log('=== ALL PHASE 3 BACKEND TESTS PASSED SUCCESSFULLY ===');
  } catch (err) {
    console.error('Test Suite Failed:', err);
    process.exit(1);
  } finally {
    if (server) server.close();
    await mongoose.connection.close();
  }
}

runTests();
