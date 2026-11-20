const http = require('http');

function request(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        hostname: '127.0.0.1',
        port: 5000,
        path: `/api${path}`,
        method,
        headers: {
          'Content-Type': 'application/json',
          ...(data && { 'Content-Length': Buffer.byteLength(data) }),
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (chunk) => (raw += chunk));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, body: JSON.parse(raw) });
          } catch (e) {
            resolve({ status: res.statusCode, body: raw });
          }
        });
      }
    );
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

async function runLiveVerification() {
  console.log('========================================================');
  console.log(' STARTING REAL BACKEND AUTHENTICATION VERIFICATION');
  console.log('========================================================');

  // 1. Health check
  const health = await request('GET', '/health');
  if (health.status !== 200 || health.body.status !== 'healthy') {
    throw new Error('Backend health check failed');
  }
  console.log('✔ [1/6] Backend health check passed (200 OK).');

  // 2. Real Login with verified customer email
  const loginRes = await request('POST', '/auth/login', {
    email: 'raiyan@tableturn.app',
    password: 'customerpassword123',
  });
  if (loginRes.status !== 200 || !loginRes.body.token) {
    throw new Error(`Login failed with status ${loginRes.status}: ${JSON.stringify(loginRes.body)}`);
  }
  if (!loginRes.body.user.isEmailVerified) {
    throw new Error('Expected raiyan@tableturn.app to be verified.');
  }
  console.log(`✔ [2/6] Verified Customer Login: SUCCESS (200 OK, isEmailVerified=${loginRes.body.user.isEmailVerified}).`);

  // 3. Real Login with phone number
  const phoneLoginRes = await request('POST', '/auth/login', {
    email: '+8801571284636',
    password: 'customerpassword123',
  });
  if (phoneLoginRes.status !== 200 || !phoneLoginRes.body.token) {
    throw new Error(`Phone number login failed with status ${phoneLoginRes.status}`);
  }
  console.log(`✔ [3/6] Phone Number Login (+8801571284636): SUCCESS (200 OK, name=${phoneLoginRes.body.user.name}).`);

  // 4. Invalid password rejection
  const badLogin = await request('POST', '/auth/login', {
    email: 'raiyan@tableturn.app',
    password: 'wrong_password_999',
  });
  if (badLogin.status !== 401) {
    throw new Error(`Expected 401 for bad password, got ${badLogin.status}`);
  }
  console.log('✔ [4/6] Invalid Password Rejection: SUCCESS (401 Unauthorized strictly enforced).');

  // 5. Real Signup with new unique account
  const timestamp = Date.now();
  const newEmail = `user_${timestamp}@tableturn.app`;
  const signupRes = await request('POST', '/auth/register', {
    name: 'New Registered Diner',
    email: newEmail,
    phone: `+8801700${Math.floor(100000 + Math.random() * 900000)}`,
    password: 'securepassword123',
  });
  if (signupRes.status !== 201 || !signupRes.body.token) {
    throw new Error(`Signup failed with status ${signupRes.status}: ${JSON.stringify(signupRes.body)}`);
  }
  if (signupRes.body.user.isEmailVerified !== false) {
    throw new Error('New account should start unverified.');
  }
  console.log(`✔ [5/6] New User Registration: SUCCESS (201 Created, Email=${newEmail}, devOtp=${signupRes.body.devOtp}).`);

  // 6. OTP Verification (using dev code 123456)
  const verifyRes = await request('POST', '/auth/verify-otp', {
    email: newEmail,
    otp: '123456',
  });
  if (verifyRes.status !== 200 || !verifyRes.body.user.isEmailVerified) {
    throw new Error(`OTP verification failed: ${JSON.stringify(verifyRes.body)}`);
  }
  console.log(`✔ [6/6] OTP Verification (Code: 123456): SUCCESS (200 OK, isEmailVerified=${verifyRes.body.user.isEmailVerified}).`);

  // 7. Post-Verification Login for new user
  const newLoginRes = await request('POST', '/auth/login', {
    email: newEmail,
    password: 'securepassword123',
  });
  if (newLoginRes.status !== 200 || !newLoginRes.body.user.isEmailVerified) {
    throw new Error(`Post-verification login failed: ${JSON.stringify(newLoginRes.body)}`);
  }
  console.log('✔ [Bonus] Post-Verification Direct Login: SUCCESS (200 OK, directly bypasses OTP to /home).');

  console.log('========================================================');
  console.log(' ALL 6 LIVE AUTHENTICATION TESTS PASSED SUCCESSFULLY! ');
  console.log('========================================================');
}

runLiveVerification().catch((err) => {
  console.error('\n❌ TEST FAILED:', err.message);
  process.exit(1);
});
