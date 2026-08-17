import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';

/**
 * Place a bid on a load (POST /api/bids)
 */
export async function placeBid(req: AuthenticatedRequest, res: Response) {
  try {
    const driverId = req.user?.userId;
    const { load_id, bid_amount_etb } = req.body;

    if (!load_id || !bid_amount_etb) {
      return res.status(400).json({
        success: false,
        message: 'Load ID and bid amount (ETB) are required.',
      });
    }

    const load = await db('loads').where({ id: load_id }).first();
    if (!load) {
      return res.status(404).json({
        success: false,
        message: 'Load not found.',
      });
    }

    if (load.status !== 'POSTED') {
      return res.status(400).json({
        success: false,
        message: 'Bids can only be placed on loads with status POSTED.',
      });
    }

    const [newBid] = await db('bids')
      .insert({
        load_id,
        driver_id: driverId,
        bid_amount_etb,
        status: 'PENDING',
      })
      .returning('*');

    return res.status(201).json({
      success: true,
      message: 'Bid submitted successfully.',
      data: newBid,
    });
  } catch (error) {
    console.error('Place Bid Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error placing bid.',
    });
  }
}

/**
 * Update bid status (PATCH /api/bids/:id/status) - Accept / Reject bid
 */
export async function updateBidStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user?.userId;
    const role = req.user?.role;

    if (!['ACCEPTED', 'REJECTED'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Status must be either ACCEPTED or REJECTED.',
      });
    }

    const bid = await db('bids').where({ id }).first();
    if (!bid) {
      return res.status(404).json({ success: false, message: 'Bid not found.' });
    }

    const load = await db('loads').where({ id: bid.load_id }).first();
    if (!load) {
      return res.status(404).json({ success: false, message: 'Associated load not found.' });
    }

    // Shipper who created the load or Admin can update bid status
    if (role === 'SHIPPER' && load.shipper_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You can only respond to bids on your own loads.',
      });
    }

    const [updatedBid] = await db('bids')
      .where({ id })
      .update({ status, updated_at: db.fn.now() })
      .returning('*');

    // If bid is ACCEPTED, update load status to MATCHED and reject other pending bids
    if (status === 'ACCEPTED') {
      await db('loads').where({ id: bid.load_id }).update({
        status: 'MATCHED',
        updated_at: db.fn.now(),
      });

      await db('bids')
        .where({ load_id: bid.load_id })
        .whereNot({ id })
        .update({ status: 'REJECTED', updated_at: db.fn.now() });
    }

    return res.status(200).json({
      success: true,
      message: `Bid status updated to ${status}.`,
      data: updatedBid,
    });
  } catch (error) {
    console.error('Update Bid Status Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error updating bid status.',
    });
  }
}
