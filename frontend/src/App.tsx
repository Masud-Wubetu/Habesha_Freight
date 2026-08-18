// // import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
// // import { AuthProvider } from './context/AuthContext';
// // import { ThemeProvider } from './context/ThemeContext';
// // import Layout from './layouts/MainLayout';
// // import DriverLayout from './layouts/DriverLayout';
// // import CompanyLayout from './layouts/CompanyLayout';

// import Home from './pages/Home';
// import Login from './pages/Login';
// import Register from './pages/Register';
// import VerifyOTP from './pages/VerifyOTP';
// import Dashboard from './pages/Dashboard';
// import Profile from './pages/Profile';
// import Shipments from './pages/Shipments';
// import CreateShipment from './pages/CreateShipment';
// import Bids from './pages/Bids';
// import Tracking from './pages/Tracking';
// import Fleet from './pages/Fleet';
// import Payments from './pages/Payments';
<<<<<<<<< Temporary merge branch 1
// Transport Company pages (imported from clean modular barrel export)
import {
  CompanyDashboard,
  FleetRequests,
  Deliveries,
  Vehicles,
  Drivers,
  CompanyProfile,
  CompanyRatings,
  CompanySettings,
} from './pages/Transport-company';
=========

import CompanyDashboard from './pages/Transport-company/Dashboard/CompanyDashboard';
import FleetRequests from './pages/Transport-company/FleetRequests/FleetRequests';
import Deliveries from './pages/Transport-company/Deliveries/Deliveries';
import Vehicles from './pages/Transport-company/Vehicles/Vehicles';
import Drivers from './pages/Transport-company/Drivers/Drivers';

>>>>>>>>> Temporary merge branch 2
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
} from "./pages/driver";

import AdminDashboard from './pages/admin/AdminDashboard';
import AdminUsers from './pages/admin/AdminUsers';
import AdminDrivers from './pages/admin/AdminDrivers';
import AdminCompanies from './pages/admin/AdminCompanies';
import AdminVehicles from './pages/admin/AdminVehicles';
import AdminDeliveries from './pages/admin/AdminDeliveries';
import AdminVerification from './pages/admin/AdminVerification';
import AdminPayments from './pages/admin/AdminPayments';
import AdminDisputes from './pages/admin/AdminDisputes';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter
        future={{
          v7_startTransition: true,
          v7_relativeSplatPath: true,
        }}
      >
        <Routes>
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
                  <Route
                    path="active-delivery/:id"
                    element={<DeliveryDetails />}
                  />
                  <Route
                    path="deliveries/active"
                    element={<ActiveDelivery />}
                  />
                  <Route
                    path="deliveries/tracking"
                    element={<LiveTracking />}
                  />
                  <Route
                    path="deliveries/history"
                    element={<DeliveryHistory />}
                  />
                  <Route path="history" element={<DeliveryHistory />} />
                  <Route path="history/tracking" element={<LiveTracking />} />
                  <Route path="ratings" element={<DriverRatings />} />
                  <Route path="messages" element={<DriverMessages />} />
                  <Route path="profile" element={<DriverInfo />} />
                  <Route path="profile/info" element={<DriverInfo />} />
                  <Route path="profile/license" element={<DriverLicense />} />
                  <Route path="profile/settings" element={<DriverSettings />} />
                  <Route
                    path="*"
                    element={<Navigate to="dashboard" replace />}
                  />
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
                  <Route
                    index
                    element={<Navigate to="dashboard" replace />}
                  />
                  <Route
                    path="dashboard"
                    element={<CompanyDashboard />}
                  />
                  <Route
                    path="fleet-requests"
                    element={<FleetRequests />}
                  />
                  <Route
                    path="deliveries"
                    element={<Deliveries />}
                  />
                  <Route
                    path="vehicles"
                    element={<Vehicles />}
                  />
                  <Route
                    path="drivers"
                    element={<Drivers />}
                  />
                  <Route
                    path="company-profile"
                    element={<CompanyProfile />}
                  />
                  <Route
                    path="ratings"
                    element={<CompanyRatings />}
                  />
                  <Route
                    path="settings"
                    element={<CompanySettings />}
                  />
                  <Route
                    path="*"
                    element={<Navigate to="dashboard" replace />}
                  />
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
                  <Route path="/" element={<Home />} />
                  <Route path="/login" element={<Login />} />
                  <Route path="/register" element={<Register />} />
                  <Route path="/verify-otp" element={<VerifyOTP />} />
                  <Route path="/dashboard" element={<Dashboard />} />
                  <Route path="/profile" element={<Profile />} />
                  <Route path="/shipments" element={<Shipments />} />
                  <Route
                    path="/shipments/create"
                    element={<CreateShipment />}
                  />
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
  );
}

export default App;
