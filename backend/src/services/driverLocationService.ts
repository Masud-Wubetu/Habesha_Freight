import db from '../config/db';

export interface DriverLocation {
  driverId: string;
  latitude: number;
  longitude: number;
  updatedAt: Date;
}

export class DriverLocationService {
  /**
   * Update a driver's last known location
   */
  static async updateLocation(
    driverId: string,
    latitude: number,
    longitude: number
  ): Promise<DriverLocation | null> {
    const hasLocation = await db.schema.hasColumn('users', 'last_known_location');
    
    if (!hasLocation) {
      // Fallback to regular columns
      await db('users')
        .where('id', driverId)
        .where('role', 'DRIVER')
        .update({
          last_lat: latitude,
          last_lng: longitude,
          updated_at: db.fn.now(),
        });

      return {
        driverId,
        latitude,
        longitude,
        updatedAt: new Date(),
      };
    }

    // Use PostGIS
    await db.raw(
      `UPDATE users 
       SET last_known_location = ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
           updated_at = NOW()
       WHERE id = ? AND role = 'DRIVER'`,
      [longitude, latitude, driverId]
    );

    return {
      driverId,
      latitude,
      longitude,
      updatedAt: new Date(),
    };
  }

  /**
   * Get a driver's last known location
   */
  static async getLocation(driverId: string): Promise<DriverLocation | null> {
    const hasLocation = await db.schema.hasColumn('users', 'last_known_location');

    if (!hasLocation) {
      const result = await db('users')
        .select('last_lat as latitude', 'last_lng as longitude', 'updated_at as updatedAt')
        .where('id', driverId)
        .where('role', 'DRIVER')
        .first();

      if (!result || result.latitude === null || result.longitude === null) {
        return null;
      }

      return {
        driverId,
        latitude: parseFloat(result.latitude),
        longitude: parseFloat(result.longitude),
        updatedAt: result.updatedAt,
      };
    }

    const result = await db.raw(
      `SELECT 
        ST_Y(last_known_location::geometry) as latitude,
        ST_X(last_known_location::geometry) as longitude,
        updated_at as "updatedAt"
       FROM users 
       WHERE id = ? AND role = 'DRIVER'`,
      [driverId]
    );

    if (!result.rows || result.rows.length === 0) {
      return null;
    }

    const row = result.rows[0];
    if (row.latitude === null || row.longitude === null) {
      return null;
    }

    return {
      driverId,
      latitude: parseFloat(row.latitude),
      longitude: parseFloat(row.longitude),
      updatedAt: row.updatedAt,
    };
  }

  /**
   * Find drivers within a radius (using PostGIS)
   */
  static async findDriversWithinRadius(
    latitude: number,
    longitude: number,
    radiusKm: number
  ): Promise<Array<{ driverId: string; distance: number }>> {
    const hasLocation = await db.schema.hasColumn('users', 'last_known_location');
    const radiusMeters = radiusKm * 1000;

    if (!hasLocation) {
      // Fallback to simple distance calculation if no PostGIS
      return [];
    }

    const result = await db.raw(
      `SELECT 
        id as "driverId",
        ROUND((ST_Distance(last_known_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) / 1000)::numeric, 2) as distance
       FROM users
       WHERE role = 'DRIVER'
         AND is_verified = true
         AND status = 'ACTIVE'
         AND kyc_status = 'APPROVED'
         AND last_known_location IS NOT NULL
         AND ST_DWithin(last_known_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)
       ORDER BY distance ASC
       LIMIT 100`,
      [longitude, latitude, longitude, latitude, radiusMeters]
    );

    return result.rows || [];
  }
}