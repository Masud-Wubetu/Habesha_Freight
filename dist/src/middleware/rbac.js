"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authorizeRoles = authorizeRoles;
/**
 * Role-Based Access Control (RBAC) middleware generator.
 * Restricts endpoint access to specified user roles.
 *
 * @param allowedRoles List of roles permitted to access the endpoint
 */
function authorizeRoles(...allowedRoles) {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Unauthorized. Please authenticate first.',
                error: { code: 'UNAUTHORIZED' },
            });
        }
        const userRole = req.user.role;
        if (!allowedRoles.includes(userRole)) {
            return res.status(403).json({
                success: false,
                message: `Forbidden. Access denied for role '${userRole}'. Required role(s): ${allowedRoles.join(', ')}.`,
                error: { code: 'FORBIDDEN' },
            });
        }
        next();
    };
}
