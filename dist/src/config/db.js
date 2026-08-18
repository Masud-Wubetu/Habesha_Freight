"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.testDbConnection = testDbConnection;
const knex_1 = __importDefault(require("knex"));
const knexfile_1 = __importDefault(require("../../knexfile"));
const environment = process.env.NODE_ENV || 'development';
const db = (0, knex_1.default)(knexfile_1.default[environment]);
async function testDbConnection() {
    try {
        await db.raw('SELECT 1+1 AS result');
        console.log('✅ PostgreSQL Connection established successfully.');
        // Ensure PostGIS extension is available
        await db.raw('CREATE EXTENSION IF NOT EXISTS postgis;');
        console.log('✅ PostGIS spatial extension enabled.');
        return true;
    }
    catch (error) {
        console.error('❌ Database connection failure:', error);
        return false;
    }
}
exports.default = db;
