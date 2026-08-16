import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';
import { SpatialService } from '../services/spatialService';

/**
 * Post a new load (POST /api/loads)
 */
export async function createLoad(req: AuthenticatedRequest, res: Response) {
  try {
    const shipperId = req.user?.userId;
    const {
      cargo_description,
      weight_tons,
      origin_city,
      destination_city,
      origin_lat,
      origin_lng,
      destination_lat,
      destination_lng,
      offered_price_etb,
    } = req.body;

    if (
      !cargo_description ||
      weight_tons === undefined ||
      !origin_city ||
      !destination_city ||
      origin_lat === undefined ||
      origin_lng === undefined ||
      destination_lat === undefined ||
      destination_lng === undefined ||
      offered_price_etb === undefined
    ) {
      return res.status(400).json({
        success: false,
        message:
          'All load details including cargo description, weight, origin, destination, coordinates, and price are required.',
      });
    }

    const [newLoad] = await db('loads')
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
      })
      .returning('*');

    return res.status(201).json({
      success: true,
      message: 'Load posted successfully.',
      data: newLoad,
    });
  } catch (error) {
    console.error('Create Load Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error posting load.',
    });
  }
}

/**
 * List loads with optional filters (GET /api/loads)
 */
export async function listLoads(req: AuthenticatedRequest, res: Response) {
  try {
    const { status, origin_city, destination_city, page = 1, limit = 20 } = req.query;
    const offset = (Number(page) - 1) * Number(limit);

    let query = db('loads')
      .join('users', 'loads.shipper_id', 'users.id')
      .select(
        'loads.*',
        'users.full_name as shipper_name',
        'users.phone_number as shipper_phone'
      );

    if (status) {
      query = query.where('loads.status', String(status));
    }
    if (origin_city) {
      query = query.whereILike('loads.origin_city', `%${origin_city}%`);
    }
    if (destination_city) {
      query = query.whereILike('loads.destination_city', `%${destination_city}%`);
    }

    const loads = await query
      .orderBy('loads.created_at', 'desc')
      .limit(Number(limit))
      .offset(offset);

    return res.status(200).json({
      success: true,
      count: loads.length,
      page: Number(page),
      data: loads,
    });
  } catch (error) {
    console.error('List Loads Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error listing loads.',
    });
  }
}

/**
 * Search nearby loads using SpatialService radius query (GET /api/loads/nearby)
 */
export async function searchNearbyLoads(req: AuthenticatedRequest, res: Response) {
  try {
    const { lat, lng, radius_km, min_capacity } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Origin latitude (lat) and longitude (lng) parameters are required.',
      });
    }

    const originLat = parseFloat(String(lat));
    const originLng = parseFloat(String(lng));
    const radiusKm = radius_km ? parseFloat(String(radius_km)) : 50;
    const minCapacityTons = min_capacity ? parseFloat(String(min_capacity)) : undefined;

    if (isNaN(originLat) || isNaN(originLng)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid coordinate numeric values.',
      });
    }

    const nearbyLoads = await SpatialService.findLoadsWithinRadius({
      originLat,
      originLng,
      radiusKm,
      minCapacityTons,
    });

    return res.status(200).json({
      success: true,
      count: nearbyLoads.length,
      radiusKm,
      data: nearbyLoads,
    });
  } catch (error) {
    console.error('Search Nearby Loads Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error searching nearby loads.',
    });
  }
}

/**
 * Get detailed load information by ID (GET /api/loads/:id)
 */
export async function getLoadDetails(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;

    const load = await db('loads')
      .join('users', 'loads.shipper_id', 'users.id')
      .select(
        'loads.*',
        'users.full_name as shipper_name',
        'users.phone_number as shipper_phone'
      )
      .where('loads.id', id)
      .first();

    if (!load) {
      return res.status(404).json({
        success: false,
        message: 'Load not found.',
      });
    }

    const bids = await db('bids')
      .join('users', 'bids.driver_id', 'users.id')
      .select(
        'bids.*',
        'users.full_name as driver_name',
        'users.phone_number as driver_phone'
      )
      .where('bids.load_id', id)
      .orderBy('bids.created_at', 'desc');

    return res.status(200).json({
      success: true,
      data: {
        ...load,
        bids,
      },
    });
  } catch (error) {
    console.error('Get Load Details Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error retrieving load details.',
    });
  }
}

/**
 * Update load status (PATCH /api/loads/:id/status)
 */
export async function updateLoadStatus(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const userId = req.user?.userId;
    const role = req.user?.role;

    const validStatuses = [
      'POSTED',
      'MATCHED',
      'DISPATCHED',
      'IN_TRANSIT',
      'DELIVERED',
      'CANCELLED',
    ];

    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
      });
    }

    const load = await db('loads').where({ id }).first();
    if (!load) {
      return res.status(404).json({ success: false, message: 'Load not found.' });
    }

    // Permission check: Shipper can update their own load, Admin can update any
    if (role === 'SHIPPER' && load.shipper_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You can only update status for your own loads.',
      });
    }

    const [updatedLoad] = await db('loads')
      .where({ id })
      .update({ status, updated_at: db.fn.now() })
      .returning('*');

    return res.status(200).json({
      success: true,
      message: `Load status updated to ${status}.`,
      data: updatedLoad,
    });
  } catch (error) {
    console.error('Update Load Status Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error updating load status.',
    });
  }
}

/**
 * Delete / Cancel load (DELETE /api/loads/:id)
 */
export async function deleteLoad(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const role = req.user?.role;

    const load = await db('loads').where({ id }).first();
    if (!load) {
      return res.status(404).json({ success: false, message: 'Load not found.' });
    }

    if (role === 'SHIPPER' && load.shipper_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You can only delete your own loads.',
      });
    }

    await db('loads').where({ id }).del();

    return res.status(200).json({
      success: true,
      message: 'Load removed successfully.',
    });
  } catch (error) {
    console.error('Delete Load Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error deleting load.',
    });
  }
}
