import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import Layout from './layouts/MainLayout';
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

function App() {
  return (
    <AuthProvider>
      <BrowserRouter future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
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
      </BrowserRouter>
    </AuthProvider>
  );
}

export default App;