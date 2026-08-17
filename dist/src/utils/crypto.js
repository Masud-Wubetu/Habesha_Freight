"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.hashPassword = hashPassword;
exports.comparePassword = comparePassword;
exports.generateOTP = generateOTP;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const crypto_1 = __importDefault(require("crypto"));
const SALT_ROUNDS = 10;
/**
 * Hashes a raw password string securely using bcrypt
 */
async function hashPassword(password) {
    return await bcryptjs_1.default.hash(password, SALT_ROUNDS);
}
/**
 * Verifies a plain password against a stored bcrypt hash
 */
async function comparePassword(plain, hashed) {
    return await bcryptjs_1.default.compare(plain, hashed);
}
/**
 * Generates a 6-digit cryptographically secure One-Time Password (OTP)
 */
function generateOTP() {
    const otp = crypto_1.default.randomInt(100000, 999999).toString();
    const expiryMinutes = Number(process.env.OTP_EXPIRY_MINUTES) || 10;
    const expiresAt = new Date(Date.now() + expiryMinutes * 60 * 1000);
    return { otp, expiresAt };
}
