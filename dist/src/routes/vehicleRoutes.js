"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const vehicleController_1 = require("../controllers/vehicleController");
const auth_1 = require("../middleware/auth");
const rbac_1 = require("../middleware/rbac");
const router = (0, express_1.Router)();
// All Vehicle endpoints require JWT Authentication
router.use(auth_1.authenticateToken);
// Drivers, Fleet Owners, and Admins can register and manage vehicles
router.post('/', (0, rbac_1.authorizeRoles)('DRIVER', 'FLEET_OWNER', 'ADMIN'), vehicleController_1.registerVehicle);
router.get('/', vehicleController_1.listVehicles);
router.get('/:id', vehicleController_1.getVehicleDetails);
router.patch('/:id', (0, rbac_1.authorizeRoles)('DRIVER', 'FLEET_OWNER', 'ADMIN'), vehicleController_1.updateVehicle);
router.delete('/:id', (0, rbac_1.authorizeRoles)('DRIVER', 'FLEET_OWNER', 'ADMIN'), vehicleController_1.deleteVehicle);
exports.default = router;
