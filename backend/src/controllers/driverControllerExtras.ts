import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';
import { FileService } from '../services/fileService';

export async function getDriverProfile(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    const driver = await db('users')
      .select(
        'id', 'full_name', 'phone_number', 'email', 'profile_photo_url',
        'kyc_status', 'is_verified', 'status', 'license_number', 'license_photo_url',
        'created_at'
      )
      .where('id', userId)
      .where('role', 'DRIVER')
      .first();

    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver profile not found.' });
    }

    const totalShipments = await db('shipments').where('carrier_id', userId).count('* as count').first();
    const inTransit = await db('shipments').where('carrier_id', userId).where('status', 'IN_TRANSIT').count('* as count').first();
    const delivered = await db('shipments').where('carrier_id', userId).where('status', 'DELIVERED').count('* as count').first();

    return res.status(200).json({
      success: true,
      data: {
        ...driver,
        stats: {
          total_shipments: Number(totalShipments?.count || 0),
          active_shipments: Number(inTransit?.count || 0),
          completed_shipments: Number(delivered?.count || 0),
        },
      },
    });
  } catch (error) {
    console.error('Get Driver Profile Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving driver profile.' });
  }
}

export async function updateDriverProfile(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const { full_name, email, phone_number, license_number } = req.body;

    const updateData: Record<string, any> = {};
    if (full_name) updateData.full_name = full_name;
    if (email !== undefined) updateData.email = email;
    if (phone_number) updateData.phone_number = phone_number;
    if (license_number) updateData.license_number = license_number;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ success: false, message: 'No fields provided for update.' });
    }

    const [updated] = await db('users')
      .where('id', userId)
      .where('role', 'DRIVER')
      .update(updateData)
      .returning(['id', 'full_name', 'phone_number', 'email', 'profile_photo_url', 'license_number']);

    if (!updated) {
      return res.status(404).json({ success: false, message: 'Driver profile not found.' });
    }

    return res.status(200).json({ success: true, message: 'Profile updated successfully.', data: updated });
  } catch (error) {
    console.error('Update Driver Profile Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error updating profile.' });
  }
}

export async function uploadDriverProfilePhoto(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const file = req.file;

    if (!file) {
      return res.status(400).json({ success: false, message: 'No file uploaded.' });
    }

    const validation = FileService.validateFile(file);
    if (!validation.valid) {
      return res.status(400).json({ success: false, message: validation.error });
    }

    const fileUrl = await FileService.saveFile(file.buffer, file.originalname, userId, 'profile');

    const [updated] = await db('users')
      .where('id', userId)
      .update({ profile_photo_url: fileUrl })
      .returning(['id', 'profile_photo_url']);

    return res.status(200).json({
      success: true,
      message: 'Profile photo uploaded successfully.',
      data: { profile_photo_url: updated.profile_photo_url },
    });
  } catch (error) {
    console.error('Upload Driver Profile Photo Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error uploading photo.' });
  }
}

export async function removeDriverProfilePhoto(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    const user = await db('users').where('id', userId).where('role', 'DRIVER').first();
    if (!user) {
      return res.status(404).json({ success: false, message: 'Driver profile not found.' });
    }

    if (user.profile_photo_url) {
      await FileService.deleteFile(user.profile_photo_url);
    }

    await db('users').where('id', userId).update({ profile_photo_url: null });

    return res.status(200).json({ success: true, message: 'Profile photo removed successfully.' });
  } catch (error) {
    console.error('Remove Driver Profile Photo Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error removing photo.' });
  }
}

export async function getDriverStats(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    const total = await db('shipments').where('carrier_id', userId).count('* as count').first();
    const inTransit = await db('shipments').where('carrier_id', userId).where('status', 'IN_TRANSIT').count('* as count').first();
    const delivered = await db('shipments').where('carrier_id', userId).where('status', 'DELIVERED').count('* as count').first();
    const assigned = await db('shipments').where('carrier_id', userId).where('status', 'ASSIGNED').count('* as count').first();
    const disputed = await db('shipments').where('carrier_id', userId).where('status', 'DISPUTED').count('* as count').first();

    const earnings = await db('escrow_ledger')
      .where('beneficiary_id', userId)
      .where('status', 'RELEASED')
      .sum('net_payout_amount_etb as total_earnings')
      .first();

    const rating = await db('reviews')
      .where('reviewee_id', userId)
      .where('target_type', 'DRIVER')
      .select(
        db.raw('COALESCE(AVG(rating), 0) as average_rating'),
        db.raw('COUNT(*) as total_ratings')
      )
      .first();

    return res.status(200).json({
      success: true,
      data: {
        shipments: {
          total: Number(total?.count || 0),
          in_transit: Number(inTransit?.count || 0),
          delivered: Number(delivered?.count || 0),
          assigned: Number(assigned?.count || 0),
          disputed: Number(disputed?.count || 0),
        },
        earnings: Number(earnings?.total_earnings || 0),
        rating: {
          average: Number(rating?.average_rating || 0),
          total: Number(rating?.total_ratings || 0),
        },
      },
    });
  } catch (error) {
    console.error('Get Driver Stats Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving stats.' });
  }
}

export async function acceptLoadPrice(req: AuthenticatedRequest, res: Response) {
  try {
    const driverId = req.user?.userId;
    const { id } = req.params;

    const load = await db('loads')
      .where('id', id)
      .where('status', 'POSTED')
      .first();

    if (!load) {
      return res.status(404).json({ success: false, message: 'Load not found or not available.' });
    }

    const vehicle = await db('vehicles')
      .where('driver_id', driverId)
      .where('is_active', true)
      .where('verification_status', 'VERIFIED')
      .where('capacity_tons', '>=', load.weight_tons)
      .orderBy('capacity_tons', 'asc')
      .first();

    if (!vehicle) {
      return res.status(400).json({
        success: false,
        message: 'You do not have a verified vehicle with sufficient capacity for this load.',
      });
    }

    const [bid] = await db('bids')
      .insert({
        load_id: id,
        driver_id: driverId,
        vehicle_id: vehicle.id,
        bid_amount_etb: load.offered_price_etb,
        status: 'PENDING',
        is_auto_accept: true,
      })
      .returning('*');

    await db('bids').where('id', bid.id).update({ status: 'ACCEPTED' });
    await db('bids').where('load_id', id).whereNot('id', bid.id).update({ status: 'REJECTED' });
    await db('loads').where('id', id).update({ status: 'MATCHED' });

    const bcrypt = await import('bcryptjs');
    const pickupOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const deliveryOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const pickupHash = await bcrypt.default.hash(pickupOtp, 10);
    const deliveryHash = await bcrypt.default.hash(deliveryOtp, 10);

    const [shipment] = await db('shipments')
      .insert({
        load_id: id,
        carrier_id: driverId,
        vehicle_id: vehicle.id,
        status: 'ASSIGNED',
        pickup_otp_hash: pickupHash,
        delivery_otp_hash: deliveryHash,
      })
      .returning('*');

    const gross = Number(load.offered_price_etb);
    const commission = gross * 0.05;
    const net = gross - commission;

    await db('escrow_ledger').insert({
      shipment_id: shipment.id,
      payer_id: load.shipper_id,
      beneficiary_id: driverId,
      gross_amount_etb: gross,
      commission_amount_etb: commission,
      net_payout_amount_etb: net,
      idempotency_key: `ESCROW-${shipment.id}`,
      status: 'PENDING',
    });

    return res.status(200).json({
      success: true,
      message: 'Load accepted successfully.',
      data: {
        load,
        shipment,
        vehicle,
        otps: { pickup: pickupOtp, delivery: deliveryOtp },
      },
    });
  } catch (error) {
    console.error('Accept Load Price Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error accepting load.' });
  }
}

export async function cancelDriverBid(req: AuthenticatedRequest, res: Response) {
  try {
    const driverId = req.user?.userId;
    const { bid_id } = req.params;

    const bid = await db('bids')
      .where('id', bid_id)
      .where('driver_id', driverId)
      .first();

    if (!bid) {
      return res.status(404).json({ success: false, message: 'Bid not found.' });
    }

    if (bid.status !== 'PENDING') {
      return res.status(400).json({ success: false, message: `Cannot cancel bid with status: ${bid.status}` });
    }

    const [cancelled] = await db('bids')
      .where('id', bid_id)
      .update({ status: 'CANCELLED' })
      .returning('*');

    return res.status(200).json({
      success: true,
      message: 'Bid cancelled successfully.',
      data: cancelled,
    });
  } catch (error) {
    console.error('Cancel Driver Bid Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error cancelling bid.' });
  }
}

export async function getDriverEarnings(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const { period = 'all' } = req.query;

    let query = db('escrow_ledger')
      .where('beneficiary_id', userId)
      .where('status', 'RELEASED');

    if (period === 'month') {
      query = query.where('released_at', '>=', db.raw("NOW() - INTERVAL '30 days'"));
    } else if (period === 'week') {
      query = query.where('released_at', '>=', db.raw("NOW() - INTERVAL '7 days'"));
    }

    const earnings = await query
      .select(
        db.raw('COALESCE(SUM(net_payout_amount_etb), 0) as total_earnings'),
        db.raw('COUNT(*) as total_transactions'),
        db.raw('COALESCE(AVG(net_payout_amount_etb), 0) as average_transaction')
      )
      .first();

    const monthlyBreakdown = await db('escrow_ledger')
      .where('beneficiary_id', userId)
      .where('status', 'RELEASED')
      .select(
        db.raw("TO_CHAR(released_at, 'YYYY-MM') as month"),
        db.raw('COALESCE(SUM(net_payout_amount_etb), 0) as total')
      )
      .groupByRaw("TO_CHAR(released_at, 'YYYY-MM')")
      .orderBy('month', 'desc')
      .limit(12);

    return res.status(200).json({
      success: true,
      data: {
        summary: {
          total_earnings: Number(earnings?.total_earnings || 0),
          total_transactions: Number(earnings?.total_transactions || 0),
          average_transaction: Number(earnings?.average_transaction || 0),
        },
        monthly_breakdown: monthlyBreakdown.map((m: any) => ({
          month: m.month,
          total: Number(m.total || 0),
        })),
      },
    });
  } catch (error) {
    console.error('Get Driver Earnings Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving earnings.' });
  }
}

export async function getDriverEarningsHistory(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const { page = 1, limit = 20 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);

    const query = db('escrow_ledger')
      .where('beneficiary_id', userId)
      .where('status', 'RELEASED')
      .join('shipments', 'escrow_ledger.shipment_id', 'shipments.id')
      .join('loads', 'shipments.load_id', 'loads.id')
      .select(
        'escrow_ledger.*',
        'loads.cargo_description',
        'loads.origin_city',
        'loads.destination_city',
        'shipments.status as shipment_status'
      )
      .orderBy('escrow_ledger.released_at', 'desc');

    const total = await query.clone().count('* as count').first();
    const history = await query.limit(Number(limit)).offset(offset);

    return res.status(200).json({
      success: true,
      data: history,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number(total?.count || 0),
        totalPages: Math.ceil(Number(total?.count || 0) / Number(limit)),
      },
    });
  } catch (error) {
    console.error('Get Driver Earnings History Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving earnings history.' });
  }
}
