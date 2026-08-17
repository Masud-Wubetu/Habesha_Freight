"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authenticateToken = authenticateToken;
const jwt_1 = require("../utils/jwt");
/**
 * Authentication middleware to validate Bearer JWT token in Authorization headers
 */
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access denied. Authentication token missing.',
        });
    }
    try {
        const decoded = (0, jwt_1.verifyToken)(token);
        req.user = decoded;
        next();
    }
    catch (error) {
        return res.status(401).json({
            success: false,
            message: 'Invalid or expired authentication token.',
            error: { code: 'INVALID_TOKEN' },
        });
    }
}
