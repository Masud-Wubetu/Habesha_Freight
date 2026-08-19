import { Router } from 'express';
import {
  searchNearbyDrivers,
  getDriverDetails,
  updateDriverLocation,
  getDriverLocation,
} from '../controllers/driverController';
import { authenticateToken } from '../middleware/auth';
import { authorizeRoles } from '../middleware/rbac';

const router = Router();

// All Driver endpoints require JWT Authentication
router.use(authenticateToken);

// Nearby driver spatial search (Shippers, Fleet Owners, Admins)
router.get(
  '/nearby',
  authorizeRoles('SHIPPER', 'FLEET_OWNER', 'ADMIN'),
  searchNearbyDrivers
);

// Driver location management (Drivers only)
router.post(
  '/location',
  authorizeRoles('DRIVER', 'ADMIN'),
  updateDriverLocation
);
router.get(
  '/location',
  authorizeRoles('DRIVER', 'ADMIN'),
  getDriverLocation
);

// Get driver details by ID (any authenticated user)
router.get('/:id', getDriverDetails);

export default router;