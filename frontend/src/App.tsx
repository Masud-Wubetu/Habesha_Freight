import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import Layout from './layouts/MainLayout';
import DriverLayout from './layouts/DriverLayout';
import CompanyLayout from './layouts/CompanyLayout';

// Public / Shipper pages
import {
  ShipperHome,
  Login,
  Register,
  VerifyOTP,
  ShipperDashboard,
  ShipperProfile,
  ShipperShipments,
  ShipperCreateShipment,
  ShipperBids,
  ShipperTracking,
  ShipperFleet,
  ShipperPayments,
} from './pages/shipper';

// Transport Company pages
import {
  CompanyDashboard,
  CompanyFleetRequests,
  CompanyDeliveries,
  CompanyVehicles,
  CompanyDrivers,
  CompanyRatings,
  CompanySettings,
} from './pages/company';

// Driver pages
import {
  DriverDashboard,
  IncomingRequests,
  AvailableLoads,
  RequestDetails,
  ActiveDelivery,
  DeliveryDetails,
  BidHistory,
  SubmitBid,
  DeliveryHistory,
  LiveTracking,
  DriverRatings,
  DriverMessages,
  DriverInfo,
  DriverLicense,
  DriverSettings,
} from './pages/driver';

// Admin pages
import AdminDashboard from './pages/admin/AdminDashboard';
import AdminUsers from './pages/admin/AdminUsers';
import AdminDrivers from './pages/admin/AdminDrivers';
import AdminCompanies from './pages/admin/AdminCompanies';
import AdminVehicles from './pages/admin/AdminVehicles';
import AdminDeliveries from './pages/admin/AdminDeliveries';
import AdminVerification from './pages/admin/AdminVerification';
import AdminPayments from './pages/admin/AdminPayments';
import AdminDisputes from './pages/admin/AdminDisputes';
import AdminReports from './pages/admin/AdminReports';
import AdminAuditLogs from './pages/admin/AdminAuditLogs';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <BrowserRouter
          future={{
            v7_startTransition: true,
            v7_relativeSplatPath: true,
          }}
        >
          <Routes>
            {/* ── Admin portal routes ── */}
            <Route path="/admin" element={<AdminDashboard />} />
            <Route path="/admin/users" element={<AdminUsers />} />
            <Route path="/admin/drivers" element={<AdminDrivers />} />
            <Route path="/admin/companies" element={<AdminCompanies />} />
            <Route path="/admin/vehicles" element={<AdminVehicles />} />
            <Route path="/admin/deliveries" element={<AdminDeliveries />} />
            <Route path="/admin/verification" element={<AdminVerification />} />
            <Route path="/admin/payments" element={<AdminPayments />} />
            <Route path="/admin/escrow" element={<AdminPayments />} />
            <Route path="/admin/disputes" element={<AdminDisputes />} />
            <Route path="/admin/reports" element={<AdminReports />} />
            <Route path="/admin/audit-logs" element={<AdminAuditLogs />} />
            <Route path="/admin/logs" element={<AdminAuditLogs />} />
            <Route path="/admin/*" element={<AdminDashboard />} />

            {/* ── Driver portal routes ── */}
            <Route
              path="/driver/*"
              element={
                <DriverLayout>
                  <Routes>
                    <Route index element={<DriverDashboard />} />
                    <Route path="dashboard" element={<DriverDashboard />} />
                    <Route path="requests" element={<IncomingRequests />} />
                    <Route path="requests/loads" element={<AvailableLoads />} />
                    <Route path="requests/:id" element={<RequestDetails />} />
                    <Route path="bids" element={<BidHistory />} />
                    <Route path="bids/history" element={<BidHistory />} />
                    <Route path="bids/submit" element={<SubmitBid />} />
                    <Route path="active-delivery" element={<ActiveDelivery />} />
                    <Route path="active-delivery/:id" element={<DeliveryDetails />} />
                    <Route path="deliveries/active" element={<ActiveDelivery />} />
                    <Route path="deliveries/tracking" element={<LiveTracking />} />
                    <Route path="deliveries/history" element={<DeliveryHistory />} />
                    <Route path="history" element={<DeliveryHistory />} />
                    <Route path="history/tracking" element={<LiveTracking />} />
                    <Route path="ratings" element={<DriverRatings />} />
                    <Route path="messages" element={<DriverMessages />} />
                    <Route path="profile" element={<DriverInfo />} />
                    <Route path="profile/info" element={<DriverInfo />} />
                    <Route path="profile/license" element={<DriverLicense />} />
                    <Route path="profile/settings" element={<DriverSettings />} />
                    <Route path="*" element={<Navigate to="dashboard" replace />} />
                  </Routes>
                </DriverLayout>
              }
            />

            {/* ── Transport Company routes ── */}
            <Route
              path="/company/*"
              element={
                <CompanyLayout>
                  <Routes>
                    <Route index element={<Navigate to="dashboard" replace />} />
                    <Route path="dashboard" element={<CompanyDashboard />} />
                    <Route path="fleet-requests" element={<CompanyFleetRequests />} />
                    <Route path="deliveries" element={<CompanyDeliveries />} />
                    <Route path="vehicles" element={<CompanyVehicles />} />
                    <Route path="drivers" element={<CompanyDrivers />} />
                    <Route path="ratings" element={<CompanyRatings />} />
                    <Route path="settings" element={<CompanySettings />} />
                    <Route path="*" element={<Navigate to="dashboard" replace />} />
                  </Routes>
                </CompanyLayout>
              }
            />

            {/* ── Public / shipper routes (use MainLayout) ── */}
            <Route
              path="/*"
              element={
                <Layout>
                  <Routes>
                    <Route path="/" element={<ShipperHome />} />
                    <Route path="/login" element={<Login />} />
                    <Route path="/register" element={<Register />} />
                    <Route path="/verify-otp" element={<VerifyOTP />} />
                    <Route path="/dashboard" element={<ShipperDashboard />} />
                    <Route path="/profile" element={<ShipperProfile />} />
                    <Route path="/shipments" element={<ShipperShipments />} />
                    <Route path="/shipments/create" element={<ShipperCreateShipment />} />
                    <Route path="/bids" element={<ShipperBids />} />
                    <Route path="/tracking" element={<ShipperTracking />} />
                    <Route path="/fleet" element={<ShipperFleet />} />
                    <Route path="/payments" element={<ShipperPayments />} />
                    <Route path="*" element={<Navigate to="/" replace />} />
                  </Routes>
                </Layout>
              }
            />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;