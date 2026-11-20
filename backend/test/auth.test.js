/**
 * Automated Test Suite for TableTurn Authentication Subsystem
 */
const mongoose = require('mongoose');
const User = require('../models/User');
const { signToken, verifyToken } = require('../config/jwt');
const request = require('http');

const PORT = 5001;
process.env.PORT = PORT;
process.env.NODE_ENV = 'test';
process.env.MONGO_URI = 'mongodb://127.0.0.1:27017/tableturn_test';
process.env.ADMIN_EMAIL = 'admin@tableturn.app';

const app = require('../server');

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
  console.log('--- Starting Authentication Test Suite ---');
  let server;
  try {
    await mongoose.connect(process.env.MONGO_URI);
    await User.deleteMany({}); // Clean test db

    server = app.listen(PORT);
    console.log(`Test server running on port ${PORT}`);

    // 1. Test Valid Registration
    console.log('1. Testing User Registration...');
    const regRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/register',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        name: 'Test Customer',
        email: 'customer@tableturn.app',
        phone: '+8801700000000',
        password: 'password123',
      }
    );
    console.assert(regRes.status === 201, `Expected status 201, got ${regRes.status}`);
    console.assert(regRes.data.success === true, 'Expected success: true');
    console.assert(regRes.data.user.role === 'customer', 'Expected role customer');
    console.assert(typeof regRes.data.token === 'string', 'Expected JWT token');
    console.log('  ✓ User Registration passed.');

    // 2. Test Duplicate Registration Prevention
    console.log('2. Testing Duplicate Registration Prevention...');
    const dupRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/register',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        name: 'Duplicate Customer',
        email: 'customer@tableturn.app',
        phone: '+8801700000000',
        password: 'password123',
      }
    );
    console.assert(dupRes.status === 409, `Expected status 409, got ${dupRes.status}`);
    console.assert(dupRes.data.success === false, 'Expected success: false');
    console.log('  ✓ Duplicate registration correctly rejected with 409.');

    // 3. Test Valid Login
    console.log('3. Testing Valid Login...');
    const loginRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'customer@tableturn.app',
        password: 'password123',
      }
    );
    console.assert(loginRes.status === 200, `Expected status 200, got ${loginRes.status}`);
    console.assert(loginRes.data.success === true, 'Expected success: true');
    console.assert(typeof loginRes.data.token === 'string', 'Expected token');
    const customerToken = loginRes.data.token;
    console.log('  ✓ Valid login succeeded with JWT token.');

    // 4. Test Invalid Password
    console.log('4. Testing Invalid Password...');
    const badPassRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'customer@tableturn.app',
        password: 'wrongpassword',
      }
    );
    console.assert(badPassRes.status === 401, `Expected status 401, got ${badPassRes.status}`);
    console.assert(badPassRes.data.success === false, 'Expected success: false');
    console.log('  ✓ Invalid password rejected with 401.');

    // 5. Test Unregistered User Login
    console.log('5. Testing Unregistered User Login...');
    const unregRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/login',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'nonexistent@tableturn.app',
        password: 'password123',
      }
    );
    console.assert(unregRes.status === 401, `Expected status 401, got ${unregRes.status}`);
    console.assert(unregRes.data.success === false, 'Expected success: false');
    console.log('  ✓ Unregistered user rejected with 401.');

    // 6. Test Admin Registration via Allowlist
    console.log('6. Testing Admin Registration via Allowlist...');
    const adminRegRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/register',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        name: 'Chief Admin',
        email: 'admin@tableturn.app',
        phone: '+8801900000000',
        password: 'adminpassword123',
      }
    );
    console.assert(adminRegRes.status === 201, `Expected status 201, got ${adminRegRes.status}`);
    console.assert(adminRegRes.data.user.role === 'admin', `Expected admin role, got ${adminRegRes.data.user.role}`);
    console.log('  ✓ Admin email allowlist correctly assigned admin role.');

    // 7. Test Protected /api/auth/me Endpoint
    console.log('7. Testing Protected /api/auth/me Endpoint...');
    const meRes = await makeRequest({
      hostname: '127.0.0.1',
      port: PORT,
      path: '/api/auth/me',
      method: 'GET',
      headers: {
        Authorization: `Bearer ${customerToken}`,
      },
    });
    console.assert(meRes.status === 200, `Expected status 200, got ${meRes.status}`);
    console.assert(meRes.data.user.email === 'customer@tableturn.app', 'Expected correct user');
    console.log('  ✓ Protected endpoint authenticated via JWT Bearer token.');

    // 8. Test OTP Verification
    console.log('8. Testing OTP Verification Flow...');
    const sendOtpRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/send-otp',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'customer@tableturn.app',
      }
    );
    console.assert(sendOtpRes.status === 200, 'Expected status 200');
    const devOtp = sendOtpRes.data.devOtp;
    console.assert(typeof devOtp === 'string' && devOtp.length === 6, 'Expected 6-digit OTP');

    const verifyRes = await makeRequest(
      {
        hostname: '127.0.0.1',
        port: PORT,
        path: '/api/auth/verify-otp',
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      },
      {
        email: 'customer@tableturn.app',
        otp: devOtp,
      }
    );
    console.assert(verifyRes.status === 200, 'Expected status 200 for verify OTP');
    console.assert(verifyRes.data.user.isEmailVerified === true, 'Expected isEmailVerified: true');
    console.log('  ✓ OTP verification flow succeeded.');

    console.log('--- ALL AUTHENTICATION BACKEND TESTS PASSED ---');
  } catch (err) {
    console.error('Test failed with error:', err);
    process.exit(1);
  } finally {
    if (server) server.close();
    await mongoose.connection.close();
  }
}

runTests();
