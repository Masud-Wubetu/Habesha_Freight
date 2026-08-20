import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';
import { MessageService } from '../services/messageService';
import { FileService } from '../services/fileService';

export async function getShipperProfile(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    const shipper = await db('users')
      .select('id', 'full_name', 'phone_number', 'email', 'profile_photo_url', 'kyc_status', 'is_verified', 'status', 'created_at')
      .where('id', userId)
      .where('role', 'SHIPPER')
      .first();

    if (!shipper) {
      return res.status(404).json({ success: false, message: 'Shipper profile not found.' });
    }

    const stats = await db('loads')
      .where('shipper_id', userId)
      .select(
        db.raw('COUNT(*) as total_loads'),
        db.raw('COUNT(*) FILTER (WHERE status = $1) as active_loads', ['POSTED']),
        db.raw('COUNT(*) FILTER (WHERE status = $1) as completed_loads', ['DELIVERED'])
      )
      .first();

    return res.status(200).json({
      success: true,
      data: {
        ...shipper,
        stats: {
          total_loads: Number(stats?.total_loads || 0),
          active_loads: Number(stats?.active_loads || 0),
          completed_loads: Number(stats?.completed_loads || 0),
        },
      },
    });
  } catch (error) {
    console.error('Get Shipper Profile Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving shipper profile.' });
  }
}

export async function updateShipperProfile(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const { full_name, email, phone_number } = req.body;

    const updateData: Record<string, any> = {};
    if (full_name) updateData.full_name = full_name;
    if (email !== undefined) updateData.email = email;
    if (phone_number) updateData.phone_number = phone_number;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ success: false, message: 'No fields provided for update.' });
    }

    const [updated] = await db('users')
      .where('id', userId)
      .where('role', 'SHIPPER')
      .update(updateData)
      .returning(['id', 'full_name', 'phone_number', 'email', 'profile_photo_url', 'kyc_status', 'is_verified', 'status']);

    if (!updated) {
      return res.status(404).json({ success: false, message: 'Shipper profile not found.' });
    }

    return res.status(200).json({ success: true, message: 'Profile updated successfully.', data: updated });
  } catch (error) {
    console.error('Update Shipper Profile Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error updating profile.' });
  }
}

export async function uploadProfilePhoto(req: AuthenticatedRequest, res: Response) {
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

    const fileUrl = await FileService.saveFile(file.buffer, file.originalname, userId!, 'profile');

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
    console.error('Upload Profile Photo Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error uploading photo.' });
  }
}

export async function removeProfilePhoto(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    const user = await db('users').where('id', userId).where('role', 'SHIPPER').first();
    if (!user) {
      return res.status(404).json({ success: false, message: 'Shipper profile not found.' });
    }

    if (user.profile_photo_url) {
      await FileService.deleteFile(user.profile_photo_url);
    }

    await db('users').where('id', userId).update({ profile_photo_url: null });

    return res.status(200).json({ success: true, message: 'Profile photo removed successfully.' });
  } catch (error) {
    console.error('Remove Profile Photo Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error removing photo.' });
  }
}

export async function createShipmentRequest(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const {
      cargo_description, weight_tons, origin_city, destination_city,
      origin_lat, origin_lng, destination_lat, destination_lng,
      offered_price_etb, preferred_vehicle_type, pickup_date, delivery_date, special_instructions,
    } = req.body;

    if (!cargo_description || !weight_tons || !origin_city || !destination_city ||
        !origin_lat || !origin_lng || !destination_lat || !destination_lng || !offered_price_etb) {
      return res.status(400).json({ success: false, message: 'Missing required fields.' });
    }

    const [request] = await db('loads')
      .insert({
        shipper_id: shipperId,
        cargo_description,
        weight_tons,
        origin_city,
        destination_city,
        origin_lat,
        origin_lng,
        destination_lat,
        destination_lng,
        offered_price_etb,
        status: 'POSTED',
        special_instructions: special_instructions || null,
        preferred_vehicle_type: preferred_vehicle_type || null,
        pickup_date: pickup_date || null,
        delivery_date: delivery_date || null,
      })
      .returning('*');

    return res.status(201).json({ success: true, message: 'Shipment request created successfully.', data: request });
  } catch (error) {
    console.error('Create Shipment Request Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error creating request.' });
  }
}

export async function getShipperRequests(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { status, page = 1, limit = 20 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);

    let query = db('loads').where('shipper_id', shipperId).select('*').orderBy('created_at', 'desc');
    if (status) query = query.where('status', String(status));

    const total = await query.clone().count('* as count').first();
    const requests = await query.limit(Number(limit)).offset(offset);

    return res.status(200).json({
      success: true,
      data: requests,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total: Number(total?.count || 0),
        totalPages: Math.ceil(Number(total?.count || 0) / Number(limit)),
      },
    });
  } catch (error) {
    console.error('Get Shipper Requests Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving requests.' });
  }
}

export async function cancelRequest(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { id } = req.params;

    const request = await db('loads').where('id', id).where('shipper_id', shipperId).first();
    if (!request) {
      return res.status(404).json({ success: false, message: 'Request not found.' });
    }

    if (request.status === 'DELIVERED' || request.status === 'CANCELLED') {
      return res.status(400).json({ success: false, message: `Cannot cancel request with status: ${request.status}` });
    }

    const [updated] = await db('loads').where('id', id).update({ status: 'CANCELLED' }).returning('*');

    return res.status(200).json({ success: true, message: 'Request cancelled successfully.', data: updated });
  } catch (error) {
    console.error('Cancel Request Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error cancelling request.' });
  }
}

export async function getRequestBids(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { id } = req.params;

    const request = await db('loads').where('id', id).where('shipper_id', shipperId).first();
    if (!request) {
      return res.status(404).json({ success: false, message: 'Request not found.' });
    }

    const bids = await db('bids')
      .where('load_id', id)
      .join('users', 'bids.driver_id', 'users.id')
      .select(
        'bids.*',
        'users.full_name as driver_name',
        'users.phone_number as driver_phone',
        'users.profile_photo_url as driver_photo'
      )
      .orderBy('bids.bid_amount_etb', 'asc');

    return res.status(200).json({ success: true, data: bids });
  } catch (error) {
    console.error('Get Request Bids Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving bids.' });
  }
}

export async function acceptBid(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { id, bid_id } = req.params;

    const request = await db('loads').where('id', id).where('shipper_id', shipperId).first();
    if (!request) {
      return res.status(404).json({ success: false, message: 'Request not found.' });
    }

    if (request.status !== 'POSTED') {
      return res.status(400).json({ success: false, message: `Cannot accept bid for request with status: ${request.status}` });
    }

    const bid = await db('bids').where('id', bid_id).where('load_id', id).first();
    if (!bid) {
      return res.status(404).json({ success: false, message: 'Bid not found.' });
    }

    if (bid.status !== 'PENDING') {
      return res.status(400).json({ success: false, message: `Cannot accept bid with status: ${bid.status}` });
    }

    await db('bids').where('id', bid_id).update({ status: 'ACCEPTED' });
    await db('bids').where('load_id', id).whereNot('id', bid_id).update({ status: 'REJECTED' });

    const [updatedLoad] = await db('loads').where('id', id).update({ status: 'MATCHED' }).returning('*');

    const bcrypt = await import('bcryptjs');
    const pickupOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const deliveryOtp = Math.floor(100000 + Math.random() * 900000).toString();
    const pickupHash = await bcrypt.default.hash(pickupOtp, 10);
    const deliveryHash = await bcrypt.default.hash(deliveryOtp, 10);

    const [shipment] = await db('shipments')
      .insert({
        load_id: id,
        carrier_id: bid.driver_id,
        status: 'ASSIGNED',
        pickup_otp_hash: pickupHash,
        delivery_otp_hash: deliveryHash,
      })
      .returning('*');

    const gross = Number(bid.bid_amount_etb);
    const commission = gross * 0.05;
    const net = gross - commission;

    await db('escrow_ledger').insert({
      shipment_id: shipment.id,
      payer_id: shipperId,
      beneficiary_id: bid.driver_id,
      gross_amount_etb: gross,
      commission_amount_etb: commission,
      net_payout_amount_etb: net,
      idempotency_key: `ESCROW-${shipment.id}`,
      status: 'PENDING',
    });

    return res.status(200).json({
      success: true,
      message: 'Bid accepted successfully.',
      data: {
        load: updatedLoad,
        shipment,
        otps: { pickup: pickupOtp, delivery: deliveryOtp },
      },
    });
  } catch (error) {
    console.error('Accept Bid Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error accepting bid.' });
  }
}

export async function counterOffer(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { id, bid_id } = req.params;
    const { counter_amount_etb } = req.body;

    if (!counter_amount_etb) {
      return res.status(400).json({ success: false, message: 'Counter amount is required.' });
    }

    const request = await db('loads').where('id', id).where('shipper_id', shipperId).first();
    if (!request) {
      return res.status(404).json({ success: false, message: 'Request not found.' });
    }

    const bid = await db('bids').where('id', bid_id).where('load_id', id).first();
    if (!bid) {
      return res.status(404).json({ success: false, message: 'Bid not found.' });
    }

    const [counterBid] = await db('bids')
      .insert({
        load_id: id,
        driver_id: bid.driver_id,
        bid_amount_etb: counter_amount_etb,
        status: 'PENDING',
        is_counter_offer: true,
        original_bid_id: bid_id,
      })
      .returning('*');

    return res.status(201).json({ success: true, message: 'Counter offer submitted successfully.', data: counterBid });
  } catch (error) {
    console.error('Counter Offer Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error submitting counter offer.' });
  }
}

export async function rejectBid(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { id, bid_id } = req.params;

    const request = await db('loads').where('id', id).where('shipper_id', shipperId).first();
    if (!request) {
      return res.status(404).json({ success: false, message: 'Request not found.' });
    }

    const bid = await db('bids').where('id', bid_id).where('load_id', id).first();
    if (!bid) {
      return res.status(404).json({ success: false, message: 'Bid not found.' });
    }

    if (bid.status !== 'PENDING') {
      return res.status(400).json({ success: false, message: `Cannot reject bid with status: ${bid.status}` });
    }

    const [updated] = await db('bids').where('id', bid_id).update({ status: 'REJECTED' }).returning('*');

    return res.status(200).json({ success: true, message: 'Bid rejected successfully.', data: updated });
  } catch (error) {
    console.error('Reject Bid Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error rejecting bid.' });
  }
}

export async function confirmDelivery(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { id } = req.params;

    const shipment = await db('shipments')
      .where('id', id)
      .join('loads', 'shipments.load_id', 'loads.id')
      .where('loads.shipper_id', shipperId)
      .select('shipments.*')
      .first();

    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Delivery not found.' });
    }

    if (shipment.status !== 'DELIVERED') {
      return res.status(400).json({ success: false, message: `Cannot confirm delivery with status: ${shipment.status}` });
    }

    await db('loads').where('id', shipment.load_id).update({ status: 'COMPLETED' });

    return res.status(200).json({ success: true, message: 'Delivery confirmed successfully.' });
  } catch (error) {
    console.error('Confirm Delivery Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error confirming delivery.' });
  }
}

export async function rateDriver(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { driver_id, shipment_id, rating, comment } = req.body;

    if (!driver_id || !shipment_id || !rating) {
      return res.status(400).json({ success: false, message: 'Driver ID, shipment ID, and rating are required.' });
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json({ success: false, message: 'Rating must be between 1 and 5.' });
    }

    const shipment = await db('shipments')
      .where('id', shipment_id)
      .join('loads', 'shipments.load_id', 'loads.id')
      .where('loads.shipper_id', shipperId)
      .first();

    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Shipment not found.' });
    }

    const existing = await db('reviews')
      .where('shipment_id', shipment_id)
      .where('reviewer_id', shipperId)
      .where('reviewee_id', driver_id)
      .first();

    if (existing) {
      return res.status(409).json({ success: false, message: 'You have already rated this driver for this shipment.' });
    }

    const [review] = await db('reviews')
      .insert({
        shipment_id,
        reviewer_id: shipperId,
        reviewee_id: driver_id,
        rating,
        comment: comment || null,
        target_type: 'DRIVER',
      })
      .returning('*');

    return res.status(201).json({ success: true, message: 'Driver rated successfully.', data: review });
  } catch (error) {
    console.error('Rate Driver Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error rating driver.' });
  }
}

export async function rateCompany(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { company_id, shipment_id, rating, comment } = req.body;

    if (!company_id || !shipment_id || !rating) {
      return res.status(400).json({ success: false, message: 'Company ID, shipment ID, and rating are required.' });
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json({ success: false, message: 'Rating must be between 1 and 5.' });
    }

    const shipment = await db('shipments')
      .where('id', shipment_id)
      .join('loads', 'shipments.load_id', 'loads.id')
      .where('loads.shipper_id', shipperId)
      .first();

    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Shipment not found.' });
    }

    const company = await db('users').where('id', company_id).where('role', 'FLEET_OWNER').first();
    if (!company) {
      return res.status(404).json({ success: false, message: 'Company not found.' });
    }

    const [review] = await db('reviews')
      .insert({
        shipment_id,
        reviewer_id: shipperId,
        reviewee_id: company_id,
        rating,
        comment: comment || null,
        target_type: 'COMPANY',
      })
      .returning('*');

    return res.status(201).json({ success: true, message: 'Company rated successfully.', data: review });
  } catch (error) {
    console.error('Rate Company Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error rating company.' });
  }
}

export async function getPaymentInfo(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { delivery_id } = req.params;

    const payment = await db('escrow_ledger')
      .where('shipment_id', delivery_id)
      .join('shipments', 'escrow_ledger.shipment_id', 'shipments.id')
      .join('loads', 'shipments.load_id', 'loads.id')
      .where('loads.shipper_id', shipperId)
      .select(
        'escrow_ledger.*',
        'shipments.status as shipment_status',
        'loads.cargo_description',
        'loads.origin_city',
        'loads.destination_city'
      )
      .first();

    if (!payment) {
      return res.status(404).json({ success: false, message: 'Payment information not found.' });
    }

    return res.status(200).json({ success: true, data: payment });
  } catch (error) {
    console.error('Get Payment Info Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving payment info.' });
  }
}

export async function openDispute(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const { shipment_id, category, reason } = req.body;

    if (!shipment_id || !category || !reason) {
      return res.status(400).json({ success: false, message: 'Shipment ID, category, and reason are required.' });
    }

    const shipment = await db('shipments')
      .where('id', shipment_id)
      .join('loads', 'shipments.load_id', 'loads.id')
      .where('loads.shipper_id', shipperId)
      .select('shipments.*')
      .first();

    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Shipment not found.' });
    }

    const [dispute] = await db('disputes')
      .insert({
        shipment_id,
        raised_by_id: shipperId,
        category,
        reason,
        status: 'OPEN',
      })
      .returning('*');

    await db('shipments').where('id', shipment_id).update({ status: 'DISPUTED' });
    await db('escrow_ledger').where('shipment_id', shipment_id).update({ status: 'DISPUTED' });

    return res.status(201).json({
      success: true,
      message: 'Dispute opened successfully. Shipment and escrow funds have been frozen for review.',
      data: dispute,
    });
  } catch (error) {
    console.error('Open Dispute Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error opening dispute.' });
  }
}

export async function getMessages(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const conversations = await MessageService.getConversations(userId!);
    return res.status(200).json({ success: true, data: conversations });
  } catch (error) {
    console.error('Get Messages Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error retrieving messages.' });
  }
}

export async function getThreadMessages(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const { thread_id } = req.params;
    const { limit = 50, offset = 0 } = req.query;

    const messages = await MessageService.getThreadMessages(
      thread_id,
      userId!,
      Number(limit),
      Number(offset)
    );

    return res.status(200).json({ success: true, data: messages });
  } catch (error) {
    console.error('Get Thread Messages Error:', error);
    if (error instanceof Error && error.message === 'THREAD_NOT_FOUND') {
      return res.status(404).json({ success: false, message: 'Thread not found.' });
    }
    return res.status(500).json({ success: false, message: 'Internal server error retrieving messages.' });
  }
}

export async function sendMessage(req: AuthenticatedRequest, res: Response) {
  try {
    const senderId = req.user?.userId;
    const { thread_id } = req.params;
    const { receiver_id, content } = req.body;

    if (!receiver_id || !content) {
      return res.status(400).json({ success: false, message: 'Receiver ID and content are required.' });
    }

    // Verify receiver exists
    const receiver = await db('users').where('id', receiver_id).first();
    if (!receiver) {
      return res.status(404).json({ success: false, message: 'Receiver not found.' });
    }

    const message = await MessageService.sendMessage(senderId!, receiver_id, content, thread_id);

    return res.status(201).json({
      success: true,
      message: 'Message sent successfully.',
      data: message,
    });
  } catch (error) {
    console.error('Send Message Error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error sending message.' });
  }
}
