import { Request, Response, NextFunction } from 'express';
import { verifyToken, UserPayload } from '../utils/jwt';

export interface AuthenticatedRequest extends Request {
  user?: UserPayload;
}

/**
 * Authentication middleware to validate Bearer JWT token in Authorization headers
 */
export function authenticateToken(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access denied. Authentication token missing.',
    });
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired authentication token.',
      error: { code: 'INVALID_TOKEN' },
    });
  }
}