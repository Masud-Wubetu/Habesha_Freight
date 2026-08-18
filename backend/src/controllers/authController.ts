import { Request, Response } from 'express';
import db from '../config/db';
import { hashPassword, comparePassword, generateOTP } from '../utils/crypto';
import { generateToken } from '../utils/jwt';
import { AuthenticatedRequest } from '../middleware/auth';

/**
 * Register new user (Shipper, Driver, Fleet Owner)
 */
export async function register(req: Request, res: Response) {
  try {
    const { full_name, phone_number, email, password, role } = req.body;

    if ( role === "ADMIN"){
      return res.status(403).json({
        success: false,
        message: 'Forbiden',
      })
    }
    if (!full_name || !phone_number || !password) {
      return res.status(400).json({
        success: false,
        message: 'Full name, phone number, and password are required.',
      });
    }

    const existingUser = await db('users').where({ phone_number }).first();
    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'A user with this phone number already exists.',
      });
    }

    const hashedPassword = await hashPassword(password);
    const { otp, expiresAt } = generateOTP();

    const [newUser] = await db('users')
      .insert({
        full_name,
        phone_number,
        email: email || null,
        password_hash: hashedPassword,
        role: role || 'SHIPPER',
        is_verified: false,
        otp_code: otp,
        otp_expires_at: expiresAt,
      })
      .returning(['id', 'full_name', 'phone_number', 'role', 'is_verified']);

    console.log(`📱 [SMS OTP DISPATCH] Sent OTP ${otp} to ${phone_number}`);

    return res.status(201).json({
      success: true,
      message: 'Registration successful. OTP sent for phone verification.',
      data: {
        user: newUser,
        demo_otp: otp,
      },
    });
  } catch (error) {
    console.error('Registration Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during registration.',
    });
  }
}

/**
 * Verify One-Time Password (OTP) for phone confirmation
 */
export async function verifyOtp(req: Request, res: Response) {
  try {
    const { phone_number, otp_code } = req.body;

    if (!phone_number || !otp_code) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and OTP code are required.',
      });
    }

    const user = await db('users').where({ phone_number }).first();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    if (user.otp_code !== otp_code) {
      return res.status(400).json({ success: false, message: 'Invalid OTP code.' });
    }

    if (new Date() > new Date(user.otp_expires_at)) {
      return res.status(400).json({ success: false, message: 'OTP code has expired.' });
    }

    await db('users')
      .where({ id: user.id })
      .update({ is_verified: true, otp_code: null, otp_expires_at: null });

    const token = generateToken({
      userId: user.id,
      role: user.role,
      phoneNumber: user.phone_number,
    });

    return res.status(200).json({
      success: true,
      message: 'Phone number verified successfully.',
      data: {
        token,
        user: {
          id: user.id,
          full_name: user.full_name,
          phone_number: user.phone_number,
          role: user.role,
        },
      },
    });
  } catch (error) {
    console.error('OTP Verification Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during OTP verification.',
    });
  }
}

/**
 * Resend OTP code to user's phone number
 */
export async function resendOtp(req: Request, res: Response) {
  try {
    const { phone_number } = req.body;

    if (!phone_number) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required.',
      });
    }

    const user = await db('users').where({ phone_number }).first();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    const { otp, expiresAt } = generateOTP();

    await db('users')
      .where({ id: user.id })
      .update({ otp_code: otp, otp_expires_at: expiresAt });

    console.log(`📱 [SMS OTP RESEND] Resent OTP ${otp} to ${phone_number}`);

    return res.status(200).json({
      success: true,
      message: 'New OTP generated and sent successfully.',
      data: {
        demo_otp: otp,
      },
    });
  } catch (error) {
    console.error('Resend OTP Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during OTP resend.',
    });
  }
}

/**
 * Login endpoint
 */
export async function login(req: Request, res: Response) {
  try {
    const { phone_number, password } = req.body;

    if (!phone_number || !password) {
      return res.status(400).json({
        success: false,
        message: 'Phone number and password are required.',
      });
    }

    const user = await db('users').where({ phone_number }).first();
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    const isMatch = await comparePassword(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid phone number or password.',
      });
    }

    const token = generateToken({
      userId: user.id,
      role: user.role,
      phoneNumber: user.phone_number,
    });

    return res.status(200).json({
      success: true,
      message: 'Login successful.',
      data: {
        token,
        user: {
          id: user.id,
          full_name: user.full_name,
          phone_number: user.phone_number,
          role: user.role,
          is_verified: user.is_verified,
        },
      },
    });
  } catch (error) {
    console.error('Login Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error during login.',
    });
  }
}

/**
 * Get authenticated user profile (GET /api/auth/me)
 */
export async function getMe(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    const user = await db('users')
      .select('id', 'full_name', 'phone_number', 'email', 'role', 'is_verified', 'created_at')
      .where({ id: userId })
      .first();

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error('Get Me Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error fetching user profile.',
    });
  }
}

/**
 * Update authenticated user profile (PATCH /api/auth/profile)
 */
export async function updateProfile(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const { full_name, email } = req.body;

    const updateData: Record<string, any> = {};
    if (full_name) updateData.full_name = full_name;
    if (email !== undefined) updateData.email = email;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields provided for profile update.',
      });
    }

    const [updatedUser] = await db('users')
      .where({ id: userId })
      .update(updateData)
      .returning(['id', 'full_name', 'phone_number', 'email', 'role', 'is_verified']);

    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully.',
      data: updatedUser,
    });
  } catch (error) {
    console.error('Update Profile Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error updating profile.',
    });
  }
}

/**
 * Logout user (POST /api/auth/logout)
 */
export async function logout(req: Request, res: Response) {
  return res.status(200).json({
    success: true,
    message: 'Logged out successfully. Please clear client-side token.',
  });
}
