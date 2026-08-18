"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const authController_1 = require("../controllers/authController");
const auth_1 = require("../middleware/auth");
const router = (0, express_1.Router)();
// Public Authentication Routes
router.post('/register', authController_1.register);
router.post('/login', authController_1.login);
router.post('/verify-otp', authController_1.verifyOtp);
router.post('/resend-otp', authController_1.resendOtp);
router.post('/logout', authController_1.logout);
// Protected User Routes (Require JWT Token)
router.get('/me', auth_1.authenticateToken, authController_1.getMe);
router.patch('/profile', auth_1.authenticateToken, authController_1.updateProfile);
exports.default = router;
