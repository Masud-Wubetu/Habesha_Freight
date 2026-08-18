import { Router } from 'express';
import {
  listShipments,
  getShipmentDetails,
  verifyPickupOtp,
  verifyDeliveryOtp,
} from '../controllers/shipmentController';
import { authenticateToken } from '../middleware/auth';
import { authorizeRoles } from '../middleware/rbac';

const router = Router();

router.use(authenticateToken);

router.get('/', listShipments);
router.get('/:id', getShipmentDetails);
router.post(
  '/:id/pickup-verify',
  authorizeRoles('DRIVER', 'ADMIN'),
  verifyPickupOtp
);
router.post(
  '/:id/delivery-verify',
  authorizeRoles('DRIVER', 'ADMIN'),
  verifyDeliveryOtp
);

export default router;
