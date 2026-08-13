import { Router } from 'express';
import { register, verifyOtp, login } from '../controllers/authController';

const router = Router();

// Public Authentication Routes
router.post('/register', register);
router.post('/verify-otp', verifyOtp);
router.post('/login', login);

export default router;
