import { Response } from 'express';
import db from '../config/db';
import { AuthenticatedRequest } from '../middleware/auth';
import { SpatialService } from '../services/spatialService';

/**
 * Search nearby drivers using SpatialService radius query (GET /api/drivers/nearby)
 */
export async function searchNearbyDrivers(req: AuthenticatedRequest, res: Response) {
  try {
    const { lat, lng, radius_km, min_rating, vehicle_type, capacity_tons } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Origin latitude (lat) and longitude (lng) parameters are required.',
      });
    }

    const originLat = parseFloat(String(lat));
    const originLng = parseFloat(String(lng));
    const radiusKm = radius_km ? parseFloat(String(radius_km)) : 50;
    const minRating = min_rating ? parseFloat(String(min_rating)) : undefined;
    const vehicleType = vehicle_type ? String(vehicle_type) : undefined;
    const capacityTons = capacity_tons ? parseFloat(String(capacity_tons)) : undefined;

    if (isNaN(originLat) || isNaN(originLng)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid coordinate numeric values.',
      });
    }

    if (minRating && (minRating < 0 || minRating > 5)) {
      return res.status(400).json({
        success: false,
        message: 'Minimum rating must be between 0 and 5.',
      });
    }

    if (vehicleType) {
      const validTypes = ['ISUZU_DRY', 'SINO_TRUCK', 'TRAILER', 'VAN'];
      if (!validTypes.includes(vehicleType)) {
        return res.status(400).json({
          success: false,
          message: `Invalid vehicle type. Must be one of: ${validTypes.join(', ')}`,
        });
      }
    }

    const nearbyDrivers = await SpatialService.findDriversWithinRadius({
      originLat,
      originLng,
      radiusKm,
      minRating,
      vehicleType,
      capacityTons,
    });

    return res.status(200).json({
      success: true,
      count: nearbyDrivers.length,
      radiusKm,
      data: nearbyDrivers,
    });
  } catch (error) {
    console.error('Search Nearby Drivers Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error searching nearby drivers.',
    });
  }
}

/**
 * Get driver details (GET /api/drivers/:id)
 */
export async function getDriverDetails(req: AuthenticatedRequest, res: Response) {
  try {
    const { id } = req.params;

    if (!id) {
      return res.status(400).json({
        success: false,
        message: 'Driver ID is required.',
      });
    }

    const driver = await db('users')
      .select(
        'users.id',
        'users.full_name',
        'users.phone_number',
        'users.email',
        'users.kyc_status',
        'users.is_verified',
        'users.status',
        'users.created_at',
        db.raw('COALESCE(AVG(ratings.rating), 0) as average_rating'),
        db.raw('COUNT(ratings.id) as total_ratings')
      )
      .leftJoin('ratings', function() {
        this.on('users.id', '=', 'ratings.target_id')
          .andOnVal('ratings.target_type', 'DRIVER');
      })
      .where('users.id', id)
      .where('users.role', 'DRIVER')
      .groupBy('users.id')
      .first();

    if (!driver) {
      return res.status(404).json({
        success: false,
        message: 'Driver not found.',
      });
    }

    const vehicles = await db('vehicles')
      .select(
        'id',
        'plate_number',
        'vehicle_type',
        'capacity_tons',
        'is_active',
        'verification_status'
      )
      .where('driver_id', id)
      .where('is_active', true);

    return res.status(200).json({
      success: true,
      data: {
        ...driver,
        vehicles,
      },
    });
  } catch (error) {
    console.error('Get Driver Details Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error retrieving driver details.',
    });
  }
}

/**
 * Update driver location (POST /api/drivers/location)
 */
export async function updateDriverLocation(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized. User ID not found.',
      });
    }

    const { lat, lng } = req.body;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        message: 'Latitude (lat) and longitude (lng) are required.',
      });
    }

    const latitude = parseFloat(String(lat));
    const longitude = parseFloat(String(lng));

    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid coordinate numeric values.',
      });
    }

    const user = await db('users')
      .where('id', userId)
      .where('role', 'DRIVER')
      .first();

    if (!user) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. Only drivers can update their location.',
      });
    }

    const hasLocation = await db.schema.hasColumn('users', 'last_known_location');

    if (hasLocation) {
      await db.raw(
        `UPDATE users 
         SET last_known_location = ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
             updated_at = NOW()
         WHERE id = ?`,
        [longitude, latitude, userId]
      );
    } else {
      await db('users')
        .where('id', userId)
        .update({
          last_lat: latitude,
          last_lng: longitude,
          updated_at: db.fn.now(),
        });
    }

    return res.status(200).json({
      success: true,
      message: 'Driver location updated successfully.',
      data: {
        latitude,
        longitude,
        updated_at: new Date().toISOString(),
      },
    });
  } catch (error) {
    console.error('Update Driver Location Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error updating driver location.',
    });
  }
}

/**
 * Get driver's last known location (GET /api/drivers/location)
 */
export async function getDriverLocation(req: AuthenticatedRequest, res: Response) {
  try {
    const userId = req.user?.userId;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized. User ID not found.',
      });
    }

    const hasLocation = await db.schema.hasColumn('users', 'last_known_location');

    let result;
    if (hasLocation) {
      result = await db.raw(
        `SELECT 
          ST_Y(last_known_location::geometry) as latitude,
          ST_X(last_known_location::geometry) as longitude,
          updated_at
         FROM users 
         WHERE id = ? AND role = 'DRIVER'`,
        [userId]
      );
      
      if (!result || !result.rows || result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Driver location not found.',
        });
      }

      const location = result.rows[0];
      if (location.latitude === null || location.longitude === null) {
        return res.status(404).json({
          success: false,
          message: 'Driver location not set.',
        });
      }

      return res.status(200).json({
        success: true,
        data: {
          latitude: parseFloat(location.latitude),
          longitude: parseFloat(location.longitude),
          updated_at: location.updated_at,
        },
      });
    } else {
      // Fallback to regular columns
      const result = await db('users')
        .select('last_lat as latitude', 'last_lng as longitude', 'updated_at')
        .where('id', userId)
        .where('role', 'DRIVER')
        .first();
      
      if (!result || result.latitude === null || result.longitude === null) {
        return res.status(404).json({
          success: false,
          message: 'Driver location not found.',
        });
      }

      return res.status(200).json({
        success: true,
        data: {
          latitude: parseFloat(result.latitude),
          longitude: parseFloat(result.longitude),
          updated_at: result.updated_at,
        },
      });
    }
  } catch (error) {
    console.error('Get Driver Location Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error retrieving driver location.',
    });
  }
}