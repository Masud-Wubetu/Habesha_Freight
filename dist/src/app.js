"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = createApp;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const dotenv_1 = __importDefault(require("dotenv"));
const db_1 = __importDefault(require("./config/db"));
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const adminRoutes_1 = require("./routes/adminRoutes");
dotenv_1.default.config();
function createApp(database = db_1.default) {
    const app = (0, express_1.default)();
    app.use((0, helmet_1.default)());
    app.use((0, cors_1.default)());
    app.use(express_1.default.json());
    app.use(express_1.default.urlencoded({ extended: true }));
    app.get('/health', (_req, res) => {
        res.status(200).json({ success: true, message: 'API is healthy.', data: { status: 'ok' } });
    });
    app.use('/api/auth', authRoutes_1.default);
    app.use('/api/admin', (0, adminRoutes_1.createAdminRouter)(database));
    app.use((error, _req, res, _next) => {
        if (error instanceof Error) {
            return res.status(500).json({
                success: false,
                message: 'Internal server error.',
                error: { code: error.name.toUpperCase() },
            });
        }
        return res.status(500).json({
            success: false,
            message: 'Internal server error.',
            error: { code: 'UNKNOWN_ERROR' },
        });
    });
    return app;
}
exports.default = createApp();
