import { Request, Response } from 'express';
import db from '../config/db';
import { hashPassword, comparePassword, generateOTP } from '../utils/crypto';
import { generateToken } from '../utils/jwt';

/**
 * Register new user (Shipper, Driver, Fleet Owner)
 */
export async function register(req: Request, res: Response) {
  try {
    const { full_name, phone_number, email, password, role } = req.body;

    if (!full_name || !phone_number || !password) {
      return res.status(400).json({
        success: false,
        message: 'Full name, phone number, and password are required.',
      });
    }

    // Check if user already exists
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

    // Mock SMS dispatch in dev environment
    console.log(`📱 [SMS OTP DISPATCH] Sent OTP ${otp} to ${phone_number}`);

    return res.status(201).json({
      success: true,
      message: 'Registration successful. OTP sent for phone verification.',
      data: {
        user: newUser,
        demo_otp: otp, // Returned for easy testing
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

    // Mark user as verified
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
