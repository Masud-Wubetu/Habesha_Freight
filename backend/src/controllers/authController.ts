import { Request, Response } from 'express';
import db from '../config/db';
import { hashPassword, comparePassword, generateOTP } from '../utils/crypto';
import { generateToken } from '../utils/jwt';
import { AuthenticatedRequest } from '../middleware/auth';

function normalizePhone(input: string): string {
  if (!input) return input;
  const trimmed = input.trim();
  if (trimmed.includes('@')) return trimmed.toLowerCase();
  const cleaned = trimmed.replace(/[^\d+]/g, '');
  if (cleaned.startsWith('09') && cleaned.length === 10) {
    return `+251${cleaned.slice(1)}`;
  }
  if (cleaned.startsWith('9') && cleaned.length === 9) {
    return `+251${cleaned}`;
  }
  if (cleaned.startsWith('251') && cleaned.length === 12) {
    return `+${cleaned}`;
  }
  return cleaned || trimmed;
}

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

    const formattedPhone = normalizePhone(phone_number);

    // Admin auto‑creation
    const isAdminPhone = formattedPhone === process.env.ADMIN_PHONE || phone_number === process.env.ADMIN_PHONE;
    const adminPasswordPlain = process.env.ADMIN_PASSWORD || '';

    const existingUser = await db('users')
      .where({ phone_number: formattedPhone })
      .orWhere({ phone_number: phone_number.trim() })
      .first();

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'A user with this phone number already exists.',
      });
    }

    const passwordToHash = isAdminPhone ? (adminPasswordPlain || password) : password;
    const hashedPassword = await hashPassword(passwordToHash);
    const { otp, expiresAt } = generateOTP();

    const [newUser] = await db('users')
      .insert({
        full_name,
        phone_number: formattedPhone,
        email: email || null,
        password_hash: hashedPassword,
        role: isAdminPhone ? 'ADMIN' : (role || 'SHIPPER'),
        is_verified: false,
        otp_code: otp,
        otp_expires_at: expiresAt,
      })
      .returning(['id', 'full_name', 'phone_number', 'role', 'is_verified']);

    console.log(`📱 [SMS OTP DISPATCH] Sent OTP ${otp} to ${formattedPhone}`);

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

    const formattedPhone = normalizePhone(phone_number);
    const user = await db('users')
      .where({ phone_number: formattedPhone })
      .orWhere({ phone_number: phone_number.trim() })
      .first();

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

    const formattedPhone = normalizePhone(phone_number);
    const user = await db('users')
      .where({ phone_number: formattedPhone })
      .orWhere({ phone_number: phone_number.trim() })
      .first();

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

    const input = phone_number.trim();

    // 1. Build candidates for phone / email lookup
    const candidates = [input];

    // Clean non-digit characters except leading '+'
    const cleaned = input.replace(/[^\d+]/g, '');

    if (input.includes('@')) {
      candidates.push(input.toLowerCase());
    } else {
      if (cleaned.startsWith('09') && cleaned.length === 10) {
        candidates.push(`+251${cleaned.slice(1)}`);
      } else if (cleaned.startsWith('9') && cleaned.length === 9) {
        candidates.push(`+251${cleaned}`);
      } else if (cleaned.startsWith('251') && cleaned.length === 12) {
        candidates.push(`+${cleaned}`);
      } else if (cleaned.startsWith('+251')) {
        candidates.push(cleaned);
      }
    }

    const user = await db('users')
      .whereIn('phone_number', candidates)
      .orWhereIn('email', candidates)
      .first();

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
