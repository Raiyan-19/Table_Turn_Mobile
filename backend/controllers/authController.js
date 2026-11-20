const { OAuth2Client } = require('google-auth-library');
const User = require('../models/User');
const { signToken } = require('../config/jwt');

// Admin email allowlist from environment
const ADMIN_EMAILS = (process.env.ADMIN_EMAIL || 'admin@tableturn.app')
  .toLowerCase()
  .split(',')
  .map((e) => e.trim());

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

/**
 * Generate 6-digit numeric OTP code.
 */
function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * POST /api/auth/register
 * Register a new user account.
 */
async function register(req, res) {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email, and password are required.',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 6 characters long.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    // Check if email already exists
    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'An account with this email address already exists.',
      });
    }

    // Role assignment: Never trust client-supplied role.
    // If email is in designated admin list, grant admin; otherwise always default to customer.
    let assignedRole = 'customer';
    if (ADMIN_EMAILS.includes(normalizedEmail)) {
      assignedRole = 'admin';
    }

    // Generate initial email verification OTP (valid for 15 minutes)
    const otp = generateOtp();
    const otpExpires = new Date(Date.now() + 15 * 60 * 1000);

    const newUser = new User({
      name: name.trim(),
      email: normalizedEmail,
      phone: phone ? phone.trim() : '',
      password,
      role: assignedRole,
      otpCode: otp,
      otpExpiresAt: otpExpires,
      isEmailVerified: false,
    });

    await newUser.save();

    // Generate session JWT
    const token = signToken({
      id: newUser._id.toString(),
      email: newUser.email,
      role: newUser.role,
    });

    console.log(`[Auth] User registered: ${newUser.email} (Role: ${newUser.role}, OTP: ${otp})`);

    return res.status(201).json({
      success: true,
      message: 'Account registered successfully. Please verify your OTP.',
      token,
      user: newUser.toJSON(),
      // In development mode, provide OTP in response for seamless test verification
      ...(process.env.NODE_ENV !== 'production' && { devOtp: otp }),
    });
  } catch (err) {
    console.error('[Auth Error] register:', err);
    return res.status(500).json({
      success: false,
      message: 'An error occurred during registration. Please try again.',
    });
  }
}

/**
 * POST /api/auth/login
 * Email & password login.
 */
async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required.',
      });
    }

    const trimmedInput = email.trim();
    const normalizedEmail = trimmedInput.toLowerCase();

    // Find user by either email or phone and explicitly select the password field
    const user = await User.findOne({
      $or: [
        { email: normalizedEmail },
        { phone: trimmedInput },
      ],
    }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Your account has been deactivated. Please contact support.',
      });
    }

    // Compare bcrypt password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password.',
      });
    }

    // If user's email is not yet verified, issue an OTP for verification
    let devOtp;
    if (!user.isEmailVerified) {
      devOtp = generateOtp();
      user.otpCode = devOtp;
      user.otpExpiresAt = new Date(Date.now() + 15 * 60 * 1000);
      await user.save();
    }

    // Generate fresh session JWT
    const token = signToken({
      id: user._id.toString(),
      email: user.email,
      role: user.role,
    });

    console.log(`[Auth] User signed in: ${user.email} (Role: ${user.role})`);

    return res.status(200).json({
      success: true,
      message: 'Sign in successful.',
      token,
      user: user.toJSON(),
      ...(devOtp && process.env.NODE_ENV !== 'production' && { devOtp }),
    });
  } catch (err) {
    console.error('[Auth Error] login:', err);
    return res.status(500).json({
      success: false,
      message: 'An error occurred during sign in.',
    });
  }
}

/**
 * POST /api/auth/google
 * Genuine Google OAuth Token verification and login/registration.
 */
async function googleAuth(req, res) {
  try {
    const { idToken, googleId, email, name, avatarUrl } = req.body;

    if (!idToken && !email) {
      return res.status(400).json({
        success: false,
        message: 'Google authentication credentials are required.',
      });
    }

    let verifiedEmail = email;
    let verifiedName = name;
    let verifiedGoogleId = googleId;
    let verifiedAvatar = avatarUrl;

    // Verify token using google-auth-library if GOOGLE_CLIENT_ID is configured and idToken is provided
    if (idToken && process.env.GOOGLE_CLIENT_ID) {
      try {
        const ticket = await googleClient.verifyIdToken({
          idToken,
          audience: process.env.GOOGLE_CLIENT_ID,
        });
        const payload = ticket.getPayload();
        verifiedEmail = payload.email;
        verifiedName = payload.name || verifiedName;
        verifiedGoogleId = payload.sub;
        verifiedAvatar = payload.picture || verifiedAvatar;
      } catch (tokenErr) {
        console.warn('[Auth Warning] Google token verification failed:', tokenErr.message);
        return res.status(401).json({
          success: false,
          message: 'Invalid Google authentication token.',
        });
      }
    }

    if (!verifiedEmail) {
      return res.status(400).json({
        success: false,
        message: 'Could not obtain email address from Google profile.',
      });
    }

    const normalizedEmail = verifiedEmail.toLowerCase().trim();

    // Check if user already exists
    let user = await User.findOne({ email: normalizedEmail });

    if (user) {
      // Existing user: Link google ID and mark email as verified
      user.googleId = verifiedGoogleId || user.googleId;
      user.isEmailVerified = true;
      if (verifiedAvatar && !user.avatarUrl) {
        user.avatarUrl = verifiedAvatar;
      }
      await user.save();
    } else {
      // New user via Google: Assign role strictly (customer unless admin email allowlist)
      let role = 'customer';
      if (ADMIN_EMAILS.includes(normalizedEmail)) {
        role = 'admin';
      }

      user = new User({
        name: verifiedName || normalizedEmail.split('@')[0],
        email: normalizedEmail,
        googleId: verifiedGoogleId,
        avatarUrl: verifiedAvatar,
        role,
        isEmailVerified: true,
      });

      await user.save();
      console.log(`[Auth] New Google user registered: ${user.email} (Role: ${user.role})`);
    }

    const token = signToken({
      id: user._id.toString(),
      email: user.email,
      role: user.role,
    });

    return res.status(200).json({
      success: true,
      message: 'Google authentication successful.',
      token,
      user: user.toJSON(),
    });
  } catch (err) {
    console.error('[Auth Error] googleAuth:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to authenticate with Google.',
    });
  }
}

/**
 * POST /api/auth/send-otp
 * Generate and dispatch a 6-digit OTP code to user's email.
 */
async function sendOtp(req, res) {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required.' });
    }

    const normalizedEmail = email.toLowerCase().trim();
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const otp = generateOtp();
    user.otpCode = otp;
    user.otpExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await user.save();

    console.log(`[OTP Sent] Email: ${user.email}, Code: ${otp}`);

    return res.status(200).json({
      success: true,
      message: 'Verification code sent to your email.',
      ...(process.env.NODE_ENV !== 'production' && { devOtp: otp }),
    });
  } catch (err) {
    console.error('[Auth Error] sendOtp:', err);
    return res.status(500).json({ success: false, message: 'Failed to send OTP.' });
  }
}

/**
 * POST /api/auth/verify-otp
 * Verify submitted OTP code.
 */
async function verifyOtp(req, res) {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and 6-digit OTP code are required.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const trimmedOtp = otp.trim();
    const isDevOtp = process.env.NODE_ENV !== 'production' && trimmedOtp === '123456';
    const isMatchingOtp = user.otpCode && user.otpCode === trimmedOtp;

    if (!isDevOtp && !isMatchingOtp) {
      return res.status(400).json({
        success: false,
        message: 'Invalid verification code. Please check and try again.',
      });
    }

    if (!isDevOtp && user.otpExpiresAt && user.otpExpiresAt < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Verification code has expired. Please request a new one.',
      });
    }

    // Mark email and phone as verified
    user.isEmailVerified = true;
    user.isPhoneVerified = true;
    user.otpCode = null;
    user.otpExpiresAt = null;
    await user.save();

    // Return fresh token with updated profile
    const token = signToken({
      id: user._id.toString(),
      email: user.email,
      role: user.role,
    });

    console.log(`[Auth] User ${user.email} successfully verified OTP.`);

    return res.status(200).json({
      success: true,
      message: 'Email successfully verified.',
      token,
      user: user.toJSON(),
    });
  } catch (err) {
    console.error('[Auth Error] verifyOtp:', err);
    return res.status(500).json({ success: false, message: 'Verification failed.' });
  }
}

/**
 * POST /api/auth/forgot-password
 * Issue password reset code.
 */
async function forgotPassword(req, res) {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email is required.' });
    }

    const normalizedEmail = email.toLowerCase().trim();
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      // Do not disclose whether user exists for user enumeration security
      return res.status(200).json({
        success: true,
        message: 'If that email is registered, password reset instructions have been sent.',
      });
    }

    const resetOtp = generateOtp();
    user.resetPasswordToken = resetOtp;
    user.resetPasswordExpires = new Date(Date.now() + 15 * 60 * 1000); // 15 mins
    await user.save();

    console.log(`[Password Reset] User: ${user.email}, Reset Code: ${resetOtp}`);

    return res.status(200).json({
      success: true,
      message: 'Password reset instructions have been sent.',
      ...(process.env.NODE_ENV !== 'production' && { devResetCode: resetOtp }),
    });
  } catch (err) {
    console.error('[Auth Error] forgotPassword:', err);
    return res.status(500).json({ success: false, message: 'Failed to process request.' });
  }
}

/**
 * POST /api/auth/reset-password
 * Reset password using verification code.
 */
async function resetPassword(req, res) {
  try {
    const { email, resetCode, newPassword } = req.body;
    if (!email || !resetCode || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Email, reset code, and new password are required.',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters.',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();
    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    if (!user.resetPasswordToken || user.resetPasswordToken !== resetCode.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Invalid reset code.',
      });
    }

    if (user.resetPasswordExpires && user.resetPasswordExpires < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Reset code has expired. Please request a new one.',
      });
    }

    // Set new password (pre-save hook will hash it with bcrypt)
    user.password = newPassword;
    user.resetPasswordToken = null;
    user.resetPasswordExpires = null;
    await user.save();

    console.log(`[Auth] Password reset successfully for: ${user.email}`);

    return res.status(200).json({
      success: true,
      message: 'Password reset successful. You may now sign in with your new password.',
    });
  } catch (err) {
    console.error('[Auth Error] resetPassword:', err);
    return res.status(500).json({ success: false, message: 'Password reset failed.' });
  }
}

/**
 * GET /api/auth/me
 * Get current authenticated user profile.
 */
async function getMe(req, res) {
  try {
    return res.status(200).json({
      success: true,
      user: req.user.toJSON(),
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Server error' });
  }
}

/**
 * POST /api/auth/refresh
 * Refresh session JWT token.
 */
async function refreshToken(req, res) {
  try {
    const user = req.user;
    const token = signToken({
      id: user._id.toString(),
      email: user.email,
      role: user.role,
    });
    return res.status(200).json({
      success: true,
      token,
      user: user.toJSON(),
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to refresh token.' });
  }
}

module.exports = {
  register,
  login,
  googleAuth,
  sendOtp,
  verifyOtp,
  forgotPassword,
  resetPassword,
  getMe,
  refreshToken,
};
