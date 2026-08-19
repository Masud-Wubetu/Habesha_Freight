import db from '../config/db';

export interface LocationPoint {
  latitude: number;
  longitude: number;
}

export interface NearbyLoadQuery {
  originLat: number;
  originLng: number;
  radiusKm: number;
  minCapacityTons?: number;
}

export interface NearbyVehicleQuery {
  originLat: number;
  originLng: number;
  radiusKm: number;
  minCapacityTons?: number;
  vehicleType?: string;
}

export interface NearbyDriverQuery {
  originLat: number;
  originLng: number;
  radiusKm: number;
  minRating?: number;
  vehicleType?: string;
  capacityTons?: number;
}

/**
 * Spatial service providing sub-300ms PostgreSQL + PostGIS queries
 * for corridor matching and radius-based discovery.
 */
export class SpatialService {
  /**
   * Find loads within a specified spatial radius (in kilometers) from driver's origin point
   */
  static async findLoadsWithinRadius(query: NearbyLoadQuery) {
    const { originLat, originLng, radiusKm, minCapacityTons } = query;
    const radiusMeters = radiusKm * 1000;

    // Check if PostGIS is available
    const hasPostGIS = await this.hasPostGIS();

    if (!hasPostGIS) {
      return await this.findLoadsWithinRadiusFallback(query);
    }

    let sqlQuery = db('loads')
      .select(
        'id',
        'shipper_id',
        'cargo_description',
        'weight_tons',
        'origin_city',
        'destination_city',
        'offered_price_etb',
        'status',
        db.raw(
          `ST_Y(origin_geom::geometry) as origin_lat, ST_X(origin_geom::geometry) as origin_lng`
        ),
        db.raw(
          `ST_Y(destination_geom::geometry) as dest_lat, ST_X(destination_geom::geometry) as dest_lng`
        ),
        db.raw(
          `ROUND((ST_Distance(origin_geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) / 1000)::numeric, 2) as distance_km`,
          [originLng, originLat]
        )
      )
      .where('status', 'POSTED')
      .whereNotNull('origin_geom')
      .whereRaw(
        `ST_DWithin(origin_geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)`,
        [originLng, originLat, radiusMeters]
      );

    if (minCapacityTons) {
      sqlQuery = sqlQuery.where('weight_tons', '<=', minCapacityTons);
    }

    const results = await sqlQuery.orderBy('distance_km', 'asc');
    return results;
  }

  /**
   * Fallback for loads without PostGIS
   */
  private static async findLoadsWithinRadiusFallback(query: NearbyLoadQuery) {
    const { originLat, originLng, radiusKm, minCapacityTons } = query;

    let sqlQuery = db('loads')
      .select(
        'id',
        'shipper_id',
        'cargo_description',
        'weight_tons',
        'origin_city',
        'destination_city',
        'offered_price_etb',
        'status',
        'origin_lat',
        'origin_lng',
        'destination_lat',
        'destination_lng'
      )
      .where('status', 'POSTED')
      .whereNotNull('origin_lat')
      .whereNotNull('origin_lng');

    if (minCapacityTons) {
      sqlQuery = sqlQuery.where('weight_tons', '<=', minCapacityTons);
    }

    const loads = await sqlQuery;
    
    const filtered = loads.filter(load => {
      const distance = this.haversineDistance(
        originLat,
        originLng,
        load.origin_lat,
        load.origin_lng
      );
      return distance <= radiusKm;
    });

    return filtered.map(load => ({
      ...load,
      distance_km: this.haversineDistance(
        originLat,
        originLng,
        load.origin_lat,
        load.origin_lng
      )
    })).sort((a, b) => a.distance_km - b.distance_km);
  }

  /**
   * Find vehicles within a specified spatial radius (in kilometers)
   */
  static async findVehiclesWithinRadius(query: NearbyVehicleQuery) {
    const { originLat, originLng, radiusKm, minCapacityTons, vehicleType } = query;
    const radiusMeters = radiusKm * 1000;

    const hasPostGIS = await this.hasPostGIS();

    if (!hasPostGIS) {
      return await this.findVehiclesWithinRadiusFallback(query);
    }

    // Check if vehicles table has origin_geom
    const hasGeom = await db.schema.hasColumn('vehicles', 'origin_geom');

    let sqlQuery = db('vehicles')
      .select(
        'vehicles.id',
        'vehicles.driver_id',
        'vehicles.plate_number',
        'vehicles.vehicle_type',
        'vehicles.capacity_tons',
        'vehicles.is_active',
        'vehicles.verification_status',
        'vehicles.origin_lat',
        'vehicles.origin_lng',
        'users.full_name as owner_name',
        'users.phone_number as owner_phone',
        'users.email as owner_email'
      )
      .join('users', 'vehicles.driver_id', 'users.id')
      .where('vehicles.is_active', true)
      .where('vehicles.verification_status', 'VERIFIED')
      .where('users.is_verified', true)
      .where('users.status', 'ACTIVE');

    if (hasGeom) {
      sqlQuery = sqlQuery
        .select(db.raw(
          `ROUND((ST_Distance(vehicles.origin_geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) / 1000)::numeric, 2) as distance_km`,
          [originLng, originLat]
        ))
        .whereNotNull('vehicles.origin_geom')
        .whereRaw(
          `ST_DWithin(vehicles.origin_geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)`,
          [originLng, originLat, radiusMeters]
        );
    } else {
      sqlQuery = sqlQuery
        .select(db.raw(
          `ROUND((ST_Distance(ST_SetSRID(ST_MakePoint(vehicles.origin_lng, vehicles.origin_lat), 4326)::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) / 1000)::numeric, 2) as distance_km`,
          [originLng, originLat]
        ))
        .whereNotNull('vehicles.origin_lat')
        .whereNotNull('vehicles.origin_lng')
        .whereRaw(
          `ST_DWithin(ST_SetSRID(ST_MakePoint(vehicles.origin_lng, vehicles.origin_lat), 4326)::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)`,
          [originLng, originLat, radiusMeters]
        );
    }

    if (minCapacityTons) {
      sqlQuery = sqlQuery.where('vehicles.capacity_tons', '>=', minCapacityTons);
    }

    if (vehicleType) {
      sqlQuery = sqlQuery.where('vehicles.vehicle_type', vehicleType);
    }

    const results = await sqlQuery.orderBy('distance_km', 'asc');
    return results;
  }

  /**
   * Fallback for vehicles without PostGIS
   */
  private static async findVehiclesWithinRadiusFallback(query: NearbyVehicleQuery) {
    const { originLat, originLng, radiusKm, minCapacityTons, vehicleType } = query;

    let sqlQuery = db('vehicles')
      .select(
        'vehicles.id',
        'vehicles.driver_id',
        'vehicles.plate_number',
        'vehicles.vehicle_type',
        'vehicles.capacity_tons',
        'vehicles.is_active',
        'vehicles.verification_status',
        'vehicles.origin_lat',
        'vehicles.origin_lng',
        'users.full_name as owner_name',
        'users.phone_number as owner_phone',
        'users.email as owner_email'
      )
      .join('users', 'vehicles.driver_id', 'users.id')
      .where('vehicles.is_active', true)
      .where('vehicles.verification_status', 'VERIFIED')
      .where('users.is_verified', true)
      .where('users.status', 'ACTIVE')
      .whereNotNull('vehicles.origin_lat')
      .whereNotNull('vehicles.origin_lng');

    if (minCapacityTons) {
      sqlQuery = sqlQuery.where('vehicles.capacity_tons', '>=', minCapacityTons);
    }

    if (vehicleType) {
      sqlQuery = sqlQuery.where('vehicles.vehicle_type', vehicleType);
    }

    const vehicles = await sqlQuery;
    
    const filtered = vehicles.filter(vehicle => {
      const distance = this.haversineDistance(
        originLat,
        originLng,
        vehicle.origin_lat,
        vehicle.origin_lng
      );
      return distance <= radiusKm;
    });

    return filtered.map(vehicle => ({
      ...vehicle,
      distance_km: this.haversineDistance(
        originLat,
        originLng,
        vehicle.origin_lat,
        vehicle.origin_lng
      )
    })).sort((a, b) => a.distance_km - b.distance_km);
  }

  /**
   * Find drivers within a specified spatial radius (in kilometers)
   */
  static async findDriversWithinRadius(query: NearbyDriverQuery) {
    const { originLat, originLng, radiusKm, minRating, vehicleType, capacityTons } = query;
    const radiusMeters = radiusKm * 1000;

    const hasPostGIS = await this.hasPostGIS();

    if (!hasPostGIS) {
      return await this.findDriversWithinRadiusFallback(query);
    }

    const hasLocation = await db.schema.hasColumn('users', 'last_known_location');

    if (!hasLocation) {
      return [];
    }

    let sqlQuery = db('users')
      .select(
        'users.id',
        'users.full_name',
        'users.phone_number',
        'users.email',
        'users.kyc_status',
        'users.is_verified',
        'users.status',
        db.raw(
          `ROUND((ST_Distance(users.last_known_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) / 1000)::numeric, 2) as distance_km`
        ),
        db.raw('COALESCE(AVG(ratings.rating), 0) as average_rating'),
        db.raw('COUNT(ratings.id) as total_ratings')
      )
      .leftJoin('ratings', function() {
        this.on('users.id', '=', 'ratings.target_id')
          .andOnVal('ratings.target_type', 'DRIVER');
      })
      .where('users.role', 'DRIVER')
      .where('users.is_verified', true)
      .where('users.status', 'ACTIVE')
      .where('users.kyc_status', 'APPROVED')
      .whereNotNull('users.last_known_location')
      .whereRaw(
        `ST_DWithin(users.last_known_location, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)`,
        [originLng, originLat, radiusMeters]
      );

    // If vehicle type or capacity is specified, join with vehicles
    if (vehicleType || capacityTons) {
      sqlQuery = sqlQuery
        .join('vehicles', 'users.id', 'vehicles.driver_id')
        .where('vehicles.is_active', true)
        .where('vehicles.verification_status', 'VERIFIED');
      
      if (vehicleType) {
        sqlQuery = sqlQuery.where('vehicles.vehicle_type', vehicleType);
      }
      
      if (capacityTons) {
        sqlQuery = sqlQuery.where('vehicles.capacity_tons', '>=', capacityTons);
      }
    }

    const results = await sqlQuery
      .groupBy('users.id')
      .having((builder) => {
        if (minRating) {
          builder.whereRaw('COALESCE(AVG(ratings.rating), 0) >= ?', [minRating]);
        }
      })
      .orderBy('distance_km', 'asc')
      .limit(100);

    return results;
  }

  /**
   * Fallback for drivers without PostGIS
   */
  private static async findDriversWithinRadiusFallback(query: NearbyDriverQuery) {
    const { originLat, originLng, radiusKm, minRating, vehicleType, capacityTons } = query;

    const hasLocation = await db.schema.hasColumn('users', 'last_lat') && 
                        await db.schema.hasColumn('users', 'last_lng');

    if (!hasLocation) {
      return [];
    }

    let sqlQuery = db('users')
      .select(
        'users.id',
        'users.full_name',
        'users.phone_number',
        'users.email',
        'users.kyc_status',
        'users.is_verified',
        'users.status',
        'users.last_lat',
        'users.last_lng',
        db.raw('COALESCE(AVG(ratings.rating), 0) as average_rating'),
        db.raw('COUNT(ratings.id) as total_ratings')
      )
      .leftJoin('ratings', function() {
        this.on('users.id', '=', 'ratings.target_id')
          .andOnVal('ratings.target_type', 'DRIVER');
      })
      .where('users.role', 'DRIVER')
      .where('users.is_verified', true)
      .where('users.status', 'ACTIVE')
      .where('users.kyc_status', 'APPROVED')
      .whereNotNull('users.last_lat')
      .whereNotNull('users.last_lng');

    if (vehicleType || capacityTons) {
      sqlQuery = sqlQuery
        .join('vehicles', 'users.id', 'vehicles.driver_id')
        .where('vehicles.is_active', true)
        .where('vehicles.verification_status', 'VERIFIED');
      
      if (vehicleType) {
        sqlQuery = sqlQuery.where('vehicles.vehicle_type', vehicleType);
      }
      
      if (capacityTons) {
        sqlQuery = sqlQuery.where('vehicles.capacity_tons', '>=', capacityTons);
      }
    }

    const drivers = await sqlQuery
      .groupBy('users.id');

    const filtered = drivers.filter(driver => {
      const distance = this.haversineDistance(
        originLat,
        originLng,
        driver.last_lat,
        driver.last_lng
      );
      return distance <= radiusKm && (!minRating || driver.average_rating >= minRating);
    });

    return filtered.map(driver => ({
      ...driver,
      distance_km: this.haversineDistance(
        originLat,
        originLng,
        driver.last_lat,
        driver.last_lng
      )
    })).sort((a, b) => a.distance_km - b.distance_km);
  }

  /**
   * Calculate exact geodesic distance in km between two coordinate points using PostGIS ST_Distance
   */
  static async calculateDistanceKm(
    pointA: LocationPoint,
    pointB: LocationPoint
  ): Promise<number> {
    const hasPostGIS = await this.hasPostGIS();

    if (!hasPostGIS) {
      return this.haversineDistance(pointA.latitude, pointA.longitude, pointB.latitude, pointB.longitude);
    }

    const result = await db.raw(
      `SELECT ST_Distance(
        ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
        ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography
      ) / 1000.0 as distance_km;`,
      [pointA.longitude, pointA.latitude, pointB.longitude, pointB.latitude]
    );

    return parseFloat(result.rows[0].distance_km);
  }

  /**
   * Haversine distance calculation (fallback when PostGIS is not available)
   */
  static haversineDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private static toRad(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  /**
   * Check if PostGIS extension is available
   */
  private static async hasPostGIS(): Promise<boolean> {
    try {
      const result = await db.raw(
        `SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') as exists`
      );
      return result.rows?.[0]?.exists || false;
    } catch {
      return false;
    }
  }
}