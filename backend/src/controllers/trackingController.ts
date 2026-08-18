import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';

/**
 * Record a location update point from driver (POST /api/tracking/location)
 */
export async function recordLocationPoint(req: AuthenticatedRequest, res: Response) {
  try {
    const driverId = req.user?.userId;
    const { shipment_id, latitude, longitude, speed } = req.body;

    if (!shipment_id || latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Shipment ID, latitude, and longitude are required.',
      });
    }

    const shipment = await db('shipments').where({ id: shipment_id }).first();
    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Shipment not found.' });
    }

    if (shipment.carrier_id !== driverId && req.user?.role !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You are not assigned to this active shipment.',
      });
    }

    if (shipment.status !== 'IN_TRANSIT') {
      return res.status(400).json({
        success: false,
        message: `Location updates can only be recorded for IN_TRANSIT shipments. Current status is ${shipment.status}.`,
      });
    }

    const [locationPoint] = await db('location_breadcrumbs')
      .insert({
        shipment_id,
        driver_id: driverId,
        latitude: parseFloat(String(latitude)),
        longitude: parseFloat(String(longitude)),
        speed: speed !== undefined ? parseFloat(String(speed)) : null,
      })
      .returning('*');

    return res.status(201).json({
      success: true,
      message: 'Location point recorded successfully.',
      data: locationPoint,
    });
  } catch (error) {
    console.error('Record Location Point Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error recording location point.',
    });
  }
}

/**
 * Get tracking breadcrumbs for a shipment (GET /api/tracking/:shipment_id)
 */
export async function getShipmentTracking(req: AuthenticatedRequest, res: Response) {
  try {
    const { shipment_id } = req.params;

    const shipment = await db('shipments').where({ id: shipment_id }).first();
    if (!shipment) {
      return res.status(404).json({ success: false, message: 'Shipment not found.' });
    }

    const breadcrumbs = await db('location_breadcrumbs')
      .where({ shipment_id })
      .orderBy('recorded_at', 'asc');

    const latestPoint = breadcrumbs.length > 0 ? breadcrumbs[breadcrumbs.length - 1] : null;

    return res.status(200).json({
      success: true,
      data: {
        shipment_id,
        status: shipment.status,
        latestPoint,
        breadcrumbs,
      },
    });
  } catch (error) {
    console.error('Get Shipment Tracking Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error retrieving shipment tracking.',
    });
  }
}
