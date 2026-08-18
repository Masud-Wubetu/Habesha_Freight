import { Request, Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';

/**
 * Get Escrow details by shipment ID (GET /api/escrow/:shipment_id)
 */
export async function getEscrowStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { shipment_id } = req.params;

    const escrow = await db('escrow_ledger').where({ shipment_id }).first();
    if (!escrow) {
      return res.status(404).json({ success: false, message: 'Escrow ledger record not found.' });
    }

    return res.status(200).json({
      success: true,
      data: escrow,
    });
  } catch (error) {
    console.error('Get Escrow Status Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error retrieving escrow status.',
    });
  }
}

/**
 * Payment Webhook Handler (POST /api/escrow/webhook)
 * Idempotent escrow locking upon payment gateway confirmation (Chapa/Telebirr/ArifPay)
 */
export async function handlePaymentWebhook(req: Request, res: Response) {
  try {
    const { idempotency_key, gateway_reference, status } = req.body;

    if (!idempotency_key) {
      return res.status(400).json({
        success: false,
        message: 'Idempotency key is required.',
      });
    }

    const escrow = await db('escrow_ledger').where({ idempotency_key }).first();
    if (!escrow) {
      return res.status(404).json({
        success: false,
        message: 'Escrow transaction record not found for provided idempotency key.',
      });
    }

    // Idempotency check: If already LOCKED or RELEASED, return success without re-applying
    if (escrow.status === 'LOCKED' || escrow.status === 'RELEASED') {
      return res.status(200).json({
        success: true,
        message: `Webhook already processed. Current escrow status is ${escrow.status}.`,
        data: escrow,
      });
    }

    const newStatus = status === 'SUCCESS' || status === 'COMPLETED' ? 'LOCKED' : escrow.status;

    const [updatedEscrow] = await db('escrow_ledger')
      .where({ id: escrow.id })
      .update({
        status: newStatus,
        gateway_reference: gateway_reference || escrow.gateway_reference,
        locked_at: newStatus === 'LOCKED' ? db.fn.now() : escrow.locked_at,
        updated_at: db.fn.now(),
      })
      .returning('*');

    return res.status(200).json({
      success: true,
      message: `Escrow status updated to ${newStatus}.`,
      data: updatedEscrow,
    });
  } catch (error) {
    console.error('Escrow Webhook Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error processing payment webhook.',
    });
  }
}

/**
 * Release Escrow Funds (POST /api/escrow/:shipment_id/release)
 */
export async function releaseEscrow(req: AuthenticatedRequest, res: Response) {
  try {
    const { shipment_id } = req.params;
    const role = req.user?.role;

    if (!['ADMIN', 'SHIPPER'].includes(role || '')) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. Only shippers or administrators can trigger manual release.',
      });
    }

    const shipment = await db('shipments').where({ id: shipment_id }).first();
    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Shipment not found.' });
    }

    if (shipment.status !== 'DELIVERED') {
      return res.status(400).json({
        success: false,
        message: `Escrow can only be released for DELIVERED shipments. Current status is ${shipment.status}.`,
      });
    }

    const [updatedEscrow] = await db('escrow_ledger')
      .where({ shipment_id })
      .update({
        status: 'RELEASED',
        released_at: db.fn.now(),
        updated_at: db.fn.now(),
      })
      .returning('*');

    return res.status(200).json({
      success: true,
      message: 'Escrow released successfully to carrier net payout balance.',
      data: updatedEscrow,
    });
  } catch (error) {
    console.error('Release Escrow Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error releasing escrow.',
    });
  }
}
