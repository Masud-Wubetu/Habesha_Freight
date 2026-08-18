import { Router } from 'express';
import {
  getEscrowStatus,
  handlePaymentWebhook,
  releaseEscrow,
} from '../controllers/escrowController';
import { authenticateToken } from '../middleware/auth';

const router = Router();

// Public webhook endpoint for payment providers (Chapa, Telebirr, etc.)
router.post('/webhook', handlePaymentWebhook);

// Protected endpoints
router.use(authenticateToken);
router.get('/:shipment_id', getEscrowStatus);
router.post('/:shipment_id/release', releaseEscrow);

export default router;
