"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerVehicle = registerVehicle;
exports.listVehicles = listVehicles;
exports.getVehicleDetails = getVehicleDetails;
exports.updateVehicle = updateVehicle;
exports.deleteVehicle = deleteVehicle;
const db_1 = __importDefault(require("../config/db"));
/**
 * Register a new vehicle (POST /api/vehicles)
 */
async function registerVehicle(req, res) {
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
        const existing = await (0, db_1.default)('vehicles').where({ plate_number }).first();
        if (existing) {
            return res.status(409).json({
                success: false,
                message: 'A vehicle with this plate number is already registered.',
            });
        }
        const [newVehicle] = await (0, db_1.default)('vehicles')
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
    }
    catch (error) {
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
async function listVehicles(req, res) {
    try {
        const userId = req.user?.userId;
        const role = req.user?.role;
        let query = (0, db_1.default)('vehicles')
            .join('users', 'vehicles.driver_id', 'users.id')
            .select('vehicles.id', 'vehicles.plate_number', 'vehicles.vehicle_type', 'vehicles.capacity_tons', 'vehicles.is_active', 'users.full_name as driver_name', 'users.phone_number as driver_phone');
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
    }
    catch (error) {
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
async function getVehicleDetails(req, res) {
    try {
        const { id } = req.params;
        const vehicle = await (0, db_1.default)('vehicles')
            .join('users', 'vehicles.driver_id', 'users.id')
            .select('vehicles.id', 'vehicles.driver_id', 'vehicles.plate_number', 'vehicles.vehicle_type', 'vehicles.capacity_tons', 'vehicles.is_active', 'vehicles.created_at', 'users.full_name as driver_name', 'users.phone_number as driver_phone')
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
    }
    catch (error) {
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
async function updateVehicle(req, res) {
    try {
        const { id } = req.params;
        const userId = req.user?.userId;
        const role = req.user?.role;
        const { vehicle_type, capacity_tons, is_active } = req.body;
        const vehicle = await (0, db_1.default)('vehicles').where({ id }).first();
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
        const updateData = {};
        if (vehicle_type)
            updateData.vehicle_type = vehicle_type;
        if (capacity_tons)
            updateData.capacity_tons = capacity_tons;
        if (is_active !== undefined)
            updateData.is_active = is_active;
        const [updated] = await (0, db_1.default)('vehicles')
            .where({ id })
            .update(updateData)
            .returning('*');
        return res.status(200).json({
            success: true,
            message: 'Vehicle updated successfully.',
            data: updated,
        });
    }
    catch (error) {
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
async function deleteVehicle(req, res) {
    try {
        const { id } = req.params;
        const userId = req.user?.userId;
        const role = req.user?.role;
        const vehicle = await (0, db_1.default)('vehicles').where({ id }).first();
        if (!vehicle) {
            return res.status(404).json({ success: false, message: 'Vehicle not found.' });
        }
        if (role === 'DRIVER' && vehicle.driver_id !== userId) {
            return res.status(403).json({
                success: false,
                message: 'Forbidden. You can only delete your own vehicles.',
            });
        }
        await (0, db_1.default)('vehicles').where({ id }).del();
        return res.status(200).json({
            success: true,
            message: 'Vehicle removed successfully.',
        });
    }
    catch (error) {
        console.error('Delete Vehicle Error:', error);
        return res.status(500).json({
            success: false,
            message: 'Internal server error deleting vehicle.',
        });
    }
}
