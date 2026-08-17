"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SpatialService = void 0;
const db_1 = __importDefault(require("../config/db"));
/**
 * Spatial service providing sub-300ms PostgreSQL + PostGIS queries
 * for corridor matching and radius-based load discovery.
 */
class SpatialService {
    /**
     * Find loads within a specified spatial radius (in kilometers) from driver's origin point
     */
    static async findLoadsWithinRadius(query) {
        const { originLat, originLng, radiusKm, minCapacityTons } = query;
        const radiusMeters = radiusKm * 1000;
        let sqlQuery = (0, db_1.default)('loads')
            .select('id', 'shipper_id', 'cargo_description', 'weight_tons', 'origin_city', 'destination_city', 'offered_price_etb', 'status', db_1.default.raw(`ST_Y(origin_geom::geometry) as origin_lat, ST_X(origin_geom::geometry) as origin_lng`), db_1.default.raw(`ST_Y(destination_geom::geometry) as dest_lat, ST_X(destination_geom::geometry) as dest_lng`), db_1.default.raw(`ROUND((ST_Distance(origin_geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography) / 1000)::numeric, 2) as distance_km`, [originLng, originLat]))
            .where('status', 'POSTED')
            .whereRaw(`ST_DWithin(origin_geom, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?)`, [originLng, originLat, radiusMeters]);
        if (minCapacityTons) {
            sqlQuery = sqlQuery.where('weight_tons', '<=', minCapacityTons);
        }
        // Order by closest origin point
        const results = await sqlQuery.orderBy('distance_km', 'asc');
        return results;
    }
    /**
     * Calculate exact geodesic distance in km between two coordinate points using PostGIS ST_Distance
     */
    static async calculateDistanceKm(pointA, pointB) {
        const result = await db_1.default.raw(`SELECT ST_Distance(
        ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
        ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography
      ) / 1000.0 as distance_km;`, [pointA.longitude, pointA.latitude, pointB.longitude, pointB.latitude]);
        return parseFloat(result.rows[0].distance_km);
    }
}
exports.SpatialService = SpatialService;
