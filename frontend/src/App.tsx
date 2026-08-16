import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
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

// Driver pages
import DriverDashboard from './pages/driver/Dashboard/DriverDashboard';
import IncomingRequests from './pages/driver/Requests/IncomingRequests';
import AvailableLoads from './pages/driver/Requests/AvailableLoads';
import ActiveDelivery from './pages/driver/ActiveDelivery/ActiveDelivery';
import DeliveryHistory from './pages/driver/History/DeliveryHistory';
import DriverRatings from './pages/driver/Ratings/DriverRatings';
import DriverInfo from './pages/driver/Profile/DriverInfo';

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
                </Routes>
              </Layout>
            }
          />

          {/* ── Driver portal (use DriverLayout with sidebar) ── */}
          <Route
            path="/driver/*"
            element={
              <DriverLayout>
                <Routes>
                  <Route path="dashboard"       element={<DriverDashboard />} />
                  <Route path="requests"        element={<IncomingRequests />} />
                  <Route path="requests/loads"  element={<AvailableLoads />} />
                  <Route path="active-delivery" element={<ActiveDelivery />} />
                  <Route path="history"         element={<DeliveryHistory />} />
                  <Route path="ratings"         element={<DriverRatings />} />
                  <Route path="profile"         element={<DriverInfo />} />
                </Routes>
              </DriverLayout>
            }
          />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;