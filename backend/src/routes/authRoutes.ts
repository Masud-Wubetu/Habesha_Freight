import { Router } from 'express';
import {
  register,
  verifyOtp,
  resendOtp,
  login,
  getMe,
  updateProfile,
  logout,
} from '../controllers/authController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Public Authentication Routes
router.post('/register', register);
router.post('/login', login);
router.post('/verify-otp', verifyOtp);
router.post('/resend-otp', resendOtp);
router.post('/logout', logout);

// Protected User Routes (Require JWT Token)
router.get('/me', authenticateToken, getMe);
router.patch('/profile', authenticateToken, updateProfile);

export default router;
