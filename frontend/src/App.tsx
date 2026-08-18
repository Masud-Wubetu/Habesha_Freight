import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import Layout from './layouts/MainLayout';
import DriverLayout from './layouts/DriverLayout';

import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import VerifyOTP from './pages/VerifyOTP';
import Dashboard from './pages/Dashboard';
import Profile from './pages/Profile';
import Shipments from './pages/Shipments';
import CreateShipment from './pages/CreateShipment';
import Bids from './pages/Bids';
import Tracking from './pages/Tracking';
import Fleet from './pages/Fleet';
import Payments from './pages/Payments';

// Driver pages (imported from clean modular barrel export)
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

import AdminDashboard from './pages/admin/AdminDashboard';
import AdminUsers from './pages/admin/AdminUsers';
import AdminDrivers from './pages/admin/AdminDrivers';

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

            {/* ── Public / shipper routes (use MainLayout) ── */}
            <Route
              path="/*"
              element={
                <Layout>
                  <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/login" element={<Login />} />
                    <Route path="/register" element={<Register />} />
                    <Route path="/verify-otp" element={<VerifyOTP />} />
                    <Route path="/dashboard" element={<Dashboard />} />
                    <Route path="/profile" element={<Profile />} />
                    <Route path="/shipments" element={<Shipments />} />
                    <Route path="/shipments/create" element={<CreateShipment />} />
                    <Route path="/bids" element={<Bids />} />
                    <Route path="/tracking" element={<Tracking />} />
                    <Route path="/fleet" element={<Fleet />} />
                    <Route path="/payments" element={<Payments />} />
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