import { Router, Response } from 'express';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { authorizeRoles } from '../middleware/rbac';
import db from '../config/db';
import {
  listLoads,
  searchNearbyLoads,
  getLoadDetails,
} from '../controllers/loadController';
import { placeBid } from '../controllers/bidController';
import {
  listShipments,
  getShipmentDetails,
  verifyPickupOtp,
  verifyDeliveryOtp,
} from '../controllers/shipmentController';
import { recordLocationPoint, getShipmentTracking } from '../controllers/trackingController';
import { listReviews } from '../controllers/reviewController';

const router = Router();

// All driver routes require a valid JWT
router.use(authenticateToken);
// All driver routes require at least DRIVER or ADMIN role
router.use(authorizeRoles('DRIVER', 'ADMIN'));

// ─────────────────────────────────────────────────────────────────
// LOADS — available / nearby loads a driver can bid on
// ─────────────────────────────────────────────────────────────────

// GET /api/driver/loads/available  →  all POSTED loads (same as /api/loads?status=POSTED)
router.get('/loads/available', async (req: AuthenticatedRequest, res: Response) => {
  (req as any).query.status = 'POSTED';
  return listLoads(req, res);
});

// GET /api/driver/loads/nearby  →  spatial proximity search (lat, lng, radius_km)
router.get('/loads/nearby', searchNearbyLoads);

// GET /api/driver/loads/:id  →  details of a single load (with bids)
router.get('/loads/:id', getLoadDetails);

// ─────────────────────────────────────────────────────────────────
// BIDS — driver's own bids
// ─────────────────────────────────────────────────────────────────

// GET /api/driver/bids  →  all bids placed by this driver
router.get('/bids', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const driverId = req.user?.userId;
    const bids = await db('bids')
      .leftJoin('loads', 'bids.load_id', 'loads.id')
      .select(
        'bids.*',
        'loads.origin_city',
        'loads.destination_city',
        'loads.cargo_description',
        'loads.weight_tons',
        'loads.offered_price_etb',
        'loads.status as load_status',
      )
      .where('bids.driver_id', driverId)
      .orderBy('bids.created_at', 'desc');

    return res.status(200).json({ success: true, count: bids.length, data: bids });
  } catch (error) {
    console.error('Driver Bids Error:', error);
    return res.status(500).json({ success: false, message: 'Error fetching driver bids.' });
  }
});

// POST /api/driver/bids  →  place a new bid on a load
router.post('/bids', placeBid);

// ─────────────────────────────────────────────────────────────────
// SHIPMENTS — active / past deliveries for this driver
// ─────────────────────────────────────────────────────────────────

// GET /api/driver/shipments  →  shipments where carrier_id = this driver
router.get('/shipments', listShipments);

// GET /api/driver/shipments/:id  →  single shipment details
router.get('/shipments/:id', getShipmentDetails);

// POST /api/driver/shipments/:id/pickup-verify  →  verify pickup OTP
router.post('/shipments/:id/pickup-verify', verifyPickupOtp);

// POST /api/driver/shipments/:id/delivery-verify  →  verify delivery OTP
router.post('/shipments/:id/delivery-verify', verifyDeliveryOtp);

// ─────────────────────────────────────────────────────────────────
// TRACKING
// ─────────────────────────────────────────────────────────────────

// POST /api/driver/tracking/location  →  record driver's GPS location
router.post('/tracking/location', recordLocationPoint);

// GET /api/driver/tracking/:shipment_id  →  get tracking history for a shipment
router.get('/tracking/:shipment_id', getShipmentTracking);

// ─────────────────────────────────────────────────────────────────
// STATS — dashboard summary numbers
// ─────────────────────────────────────────────────────────────────

// GET /api/driver/stats  →  earnings, trips, active jobs, rating
router.get('/stats', async (req: AuthenticatedRequest, res: Response) => {
  try {
    const driverId = req.user?.userId;

    const [{ totalTrips }] = await db('shipments')
      .where({ carrier_id: driverId })
      .count('id as totalTrips');

    const [{ activeJobs }] = await db('shipments')
      .where({ carrier_id: driverId })
      .whereIn('status', ['ASSIGNED', 'PICKED_UP', 'IN_TRANSIT'])
      .count('id as activeJobs');

    const [{ pendingBids }] = await db('bids')
      .where({ driver_id: driverId, status: 'PENDING' })
      .count('id as pendingBids');

    const [earnings] = await db('escrow_ledger')
      .where({ beneficiary_id: driverId, status: 'RELEASED' })
      .sum('net_payout_amount_etb as total');

    const ratingRows = await db('reviews')
      .where({ reviewee_id: driverId })
      .select('rating');

    const avgRating =
      ratingRows.length > 0
        ? (ratingRows.reduce((sum: number, r: any) => sum + Number(r.rating), 0) / ratingRows.length).toFixed(1)
        : null;

    return res.status(200).json({
      success: true,
      data: {
        totalTrips: Number(totalTrips),
        activeJobs: Number(activeJobs),
        pendingBids: Number(pendingBids),
        totalEarningsEtb: Number(earnings?.total ?? 0),
        avgRating,
      },
    });
  } catch (error) {
    console.error('Driver Stats Error:', error);
    return res.status(500).json({ success: false, message: 'Error fetching driver stats.' });
  }
});

// ─────────────────────────────────────────────────────────────────
// RATINGS — driver's received reviews
// ─────────────────────────────────────────────────────────────────

// GET /api/driver/reviews  →  reviews about this driver
router.get('/reviews', listReviews);

export default router;
