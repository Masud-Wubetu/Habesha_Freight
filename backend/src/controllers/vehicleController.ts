import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';

/**
 * Register a new vehicle (POST /api/vehicles)
 */
export async function registerVehicle(req: AuthenticatedRequest, res: Response) {
  try {
    const driverId = req.user?.userId;
    const { plate_number, vehicle_type, capacity_tons } = req.body;

    if (!plate_number || !vehicle_type || !capacity_tons) {
      return res.status(400).json({
        success: false,
        message: 'Plate number, vehicle type, and capacity tons are required.',
      });
    }

    // Check if plate number already exists
    const existing = await db('vehicles').where({ plate_number }).first();
    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'A vehicle with this plate number is already registered.',
      });
    }

    const [newVehicle] = await db('vehicles')
      .insert({
        driver_id: driverId,
        plate_number,
        vehicle_type,
        capacity_tons,
        is_active: true,
      })
      .returning(['id', 'driver_id', 'plate_number', 'vehicle_type', 'capacity_tons', 'is_active', 'created_at']);

    return res.status(201).json({
      success: true,
      message: 'Vehicle registered successfully.',
      data: newVehicle,
    });
  } catch (error) {
    console.error('Register Vehicle Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error registering vehicle.',
    });
  }
}

/**
 * List accessible vehicles (GET /api/vehicles)
 */
export async function listVehicles(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;
    const role = req.user?.role;

    let query = db('vehicles')
      .join('users', 'vehicles.driver_id', 'users.id')
      .select(
        'vehicles.id',
        'vehicles.plate_number',
        'vehicles.vehicle_type',
        'vehicles.capacity_tons',
        'vehicles.is_active',
        'users.full_name as driver_name',
        'users.phone_number as driver_phone'
      );

    // Filter by owner if driver
    if (role === 'DRIVER') {
      query = query.where('vehicles.driver_id', userId);
    }

    const vehicles = await query.orderBy('vehicles.created_at', 'desc');

    return res.status(200).json({
      success: true,
      count: vehicles.length,
      data: vehicles,
    });
  } catch (error) {
    console.error('List Vehicles Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error listing vehicles.',
    });
  }
}

/**
 * Get vehicle details (GET /api/vehicles/:id)
 */
export async function getVehicleDetails(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;

    const vehicle = await db('vehicles')
      .join('users', 'vehicles.driver_id', 'users.id')
      .select(
        'vehicles.id',
        'vehicles.driver_id',
        'vehicles.plate_number',
        'vehicles.vehicle_type',
        'vehicles.capacity_tons',
        'vehicles.is_active',
        'vehicles.created_at',
        'users.full_name as driver_name',
        'users.phone_number as driver_phone'
      )
      .where('vehicles.id', id)
      .first();

    if (!vehicle) {
      return res.status(404).json({
        success: false,
        message: 'Vehicle not found.',
      });
    }

    return res.status(200).json({
      success: true,
      data: vehicle,
    });
  } catch (error) {
    console.error('Get Vehicle Details Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error retrieving vehicle details.',
    });
  }
}

/**
 * Update vehicle (PATCH /api/vehicles/:id)
 */
export async function updateVehicle(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const role = req.user?.role;
    const { vehicle_type, capacity_tons, is_active } = req.body;

    const vehicle = await db('vehicles').where({ id }).first();
    if (!vehicle) {
      return res.status(404).json({ success: false, message: 'Vehicle not found.' });
    }

    // Ownership check
    if (role === 'DRIVER' && vehicle.driver_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You can only update your own vehicles.',
      });
    }

    const updateData: Record<string, any> = {};
    if (vehicle_type) updateData.vehicle_type = vehicle_type;
    if (capacity_tons) updateData.capacity_tons = capacity_tons;
    if (is_active !== undefined) updateData.is_active = is_active;

    const [updated] = await db('vehicles')
      .where({ id })
      .update(updateData)
      .returning('*');

    return res.status(200).json({
      success: true,
      message: 'Vehicle updated successfully.',
      data: updated,
    });
  } catch (error) {
    console.error('Update Vehicle Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error updating vehicle.',
    });
  }
}

/**
 * Remove vehicle (DELETE /api/vehicles/:id)
 */
export async function deleteVehicle(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;
    const role = req.user?.role;

    const vehicle = await db('vehicles').where({ id }).first();
    if (!vehicle) {
      return res.status(404).json({ success: false, message: 'Vehicle not found.' });
    }

    if (role === 'DRIVER' && vehicle.driver_id !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You can only delete your own vehicles.',
      });
    }

    await db('vehicles').where({ id }).del();

    return res.status(200).json({
      success: true,
      message: 'Vehicle removed successfully.',
    });
  } catch (error) {
    console.error('Delete Vehicle Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error deleting vehicle.',
    });
  }
}
