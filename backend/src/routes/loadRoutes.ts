import { Router } from 'express';
import {
  createLoad,
  listLoads,
  searchNearbyLoads,
  getLoadDetails,
  updateLoadStatus,
  deleteLoad,
} from '../controllers/loadController';
import { authenticateToken } from '../middleware/auth';
import { authorizeRoles } from '../middleware/rbac';

const router = Router();

// All load endpoints require valid JWT authentication
router.use(authenticateToken);

// Nearby load spatial search (Drivers, Fleet Owners, Admins)
router.get('/nearby', searchNearbyLoads);

// List all loads with filtering
router.get('/', listLoads);

// Post a new load (Shippers, Admins)
router.post('/', authorizeRoles('SHIPPER', 'ADMIN'), createLoad);

// Get load details by ID
router.get('/:id', getLoadDetails);

// Update load status
router.patch('/:id/status', authorizeRoles('SHIPPER', 'ADMIN'), updateLoadStatus);

// Delete / Cancel load
router.delete('/:id', authorizeRoles('SHIPPER', 'ADMIN'), deleteLoad);

export default router;
