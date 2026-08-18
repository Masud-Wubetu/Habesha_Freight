import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../../services/api';
import AdminLayout from '../../layouts/AdminLayout';

interface DashboardStats {
  totalUsers: number;
  totalDrivers: number;
  totalCompanies: number;
  totalVehicles: number;
  activeDeliveries: number;
  completedDeliveries: number;
  pendingRequests: number;
  openDisputes: number;
}

interface ShipmentItem {
  id: string;
  origin: string;
  destination: string;
  status: 'In Transit' | 'Bidding' | 'Delivered' | 'Assigned';
}

interface DisputeItem {
  id: string;
  title: string;
  date: string;
  parties: string;
  shipmentId: string;
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 1842,
    totalDrivers: 284,
    totalCompanies: 18,
    totalVehicles: 196,
    activeDeliveries: 12,
    completedDeliveries: 1284,
    pendingRequests: 8,
    openDisputes: 2,
  });

  const [recentShipments] = useState<ShipmentItem[]>([
    { id: 'SHP-001', origin: 'Addis', destination: 'Dire Dawa', status: 'In Transit' },
    { id: 'SHP-002', origin: 'Adama', destination: 'Hawassa', status: 'Bidding' },
    { id: 'SHP-003', origin: 'Addis', destination: 'Bahir Dar', status: 'Delivered' },
  ]);

  const [openDisputesList] = useState<DisputeItem[]>([
    {
      id: 'DIS-001',
      title: 'Late Delivery',
      date: 'Aug 8',
      parties: 'Yohannes vs Dawit',
      shipmentId: 'SHP-002',
    },
  ]);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      const res = await api.get<{
        success: boolean;
        data?: Record<string, unknown>;
      }>('/admin/dashboard', true);

      if (res && res.success && res.data) {
        const data = res.data;
        setStats({
          totalUsers: Number(data.totalUsers ?? 1842),
          totalDrivers: Number(data.totalDrivers ?? 284),
          totalCompanies: Number(data.totalFleetOwners ?? 18),
          totalVehicles: Number(data.totalVehicles ?? 196),
          activeDeliveries: Number(data.activeShipments ?? 12),
          completedDeliveries: Number(data.completedShipments ?? 1284),
          pendingRequests: Number(data.pendingKyc ?? 8),
          openDisputes: Number(data.activeDisputes ?? 2),
        });
      }
    } catch (err) {
      console.warn('Backend API connection note: utilizing active state data.', err);
    }
  };

  const formattedDate = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  const getStatusBadgeStyle = (status: string) => {
    switch (status) {
      case 'In Transit':
        return { backgroundColor: '#E0F2FE', color: '#0284C7' };
      case 'Bidding':
        return { backgroundColor: '#FEF3C7', color: '#D97706' };
      case 'Delivered':
        return { backgroundColor: '#DCFCE7', color: '#16A34A' };
      default:
        return { backgroundColor: '#F3F4F6', color: '#4B5563' };
    }
  };

  return (
    <AdminLayout>
      <div style={{ padding: '2rem 2.5rem' }}>
        {/* Top Header Bar */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2rem' }}>
          <div>
            <h1 style={{ fontSize: '1.75rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Overview</h1>
            <div style={{ fontSize: '0.875rem', color: '#64748B', marginTop: '0.25rem' }}>{formattedDate}</div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            {/* Open Disputes Alert Pill */}
            <Link
              to="/admin/disputes"
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                backgroundColor: '#FEE2E2',
                color: '#DC2626',
                padding: '0.4rem 0.9rem',
                borderRadius: '2rem',
                fontSize: '0.85rem',
                fontWeight: 600,
                textDecoration: 'none',
              }}
            >
              <span>⚠️</span>
              <span>{stats.openDisputes} open disputes</span>
            </Link>

            {/* Dark Mode Toggle */}
            <button
              style={{
                width: '36px',
                height: '36px',
                borderRadius: '50%',
                backgroundColor: '#F1F5F9',
                border: 'none',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '1rem',
              }}
              title="Toggle Theme"
            >
              🌙
            </button>

            {/* Profile Avatar */}
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '50%',
                backgroundColor: '#C8933A',
                color: '#FFFFFF',
                fontWeight: 700,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '0.85rem',
              }}
            >
              AD
            </div>
          </div>
        </div>

        {/* Metric Cards Grid (4 columns x 2 rows) */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(4, 1fr)',
            gap: '1.25rem',
            marginBottom: '2rem',
          }}
        >
          {/* Card 1: Total Users */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#EFF6FF', color: '#3B82F6' }}>👥</div>
            <div style={valStyle}>{stats.totalUsers.toLocaleString()}</div>
            <div style={labelStyle}>Total Users</div>
          </div>

          {/* Card 2: Registered Drivers */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#FEF2F2', color: '#EF4444' }}>🚛</div>
            <div style={valStyle}>{stats.totalDrivers.toLocaleString()}</div>
            <div style={labelStyle}>Registered Drivers</div>
          </div>

          {/* Card 3: Transport Companies */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#F0FDF4', color: '#16A34A' }}>🏢</div>
            <div style={valStyle}>{stats.totalCompanies.toLocaleString()}</div>
            <div style={labelStyle}>Transport Companies</div>
          </div>

          {/* Card 4: Registered Vehicles */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#EFF6FF', color: '#2563EB' }}>🚚</div>
            <div style={valStyle}>{stats.totalVehicles.toLocaleString()}</div>
            <div style={labelStyle}>Registered Vehicles</div>
          </div>

          {/* Card 5: Active Deliveries */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#FFF7ED', color: '#EA580C' }}>🚚</div>
            <div style={valStyle}>{stats.activeDeliveries.toLocaleString()}</div>
            <div style={labelStyle}>Active Deliveries</div>
          </div>

          {/* Card 6: Completed Deliveries */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#F0FDF4', color: '#16A34A' }}>✅</div>
            <div style={valStyle}>{stats.completedDeliveries.toLocaleString()}</div>
            <div style={labelStyle}>Completed Deliveries</div>
          </div>

          {/* Card 7: Pending Requests */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#FEFCE8', color: '#CA8A04' }}>⏳</div>
            <div style={valStyle}>{stats.pendingRequests.toLocaleString()}</div>
            <div style={labelStyle}>Pending Requests</div>
          </div>

          {/* Card 8: Open Disputes */}
          <div style={cardStyle}>
            <div style={{ ...iconStyle, backgroundColor: '#FEF2F2', color: '#DC2626' }}>⚠️</div>
            <div style={valStyle}>{stats.openDisputes.toLocaleString()}</div>
            <div style={labelStyle}>Open Disputes</div>
          </div>
        </div>

        {/* Bottom Grid (2 Columns) */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem' }}>
          {/* Left Column: Recent Shipments */}
          <div style={sectionCardStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Recent Shipments</h3>
              <Link to="/admin/deliveries" style={{ fontSize: '0.85rem', color: '#C8933A', fontWeight: 600, textDecoration: 'none' }}>
                View all
              </Link>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              {recentShipments.map((shipment) => (
                <div
                  key={shipment.id}
                  style={{
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    paddingBottom: '1rem',
                    borderBottom: '1px solid #F1F5F9',
                  }}
                >
                  <div>
                    <div style={{ fontWeight: 700, fontSize: '0.95rem', color: '#0F172A' }}>{shipment.id}</div>
                    <div style={{ fontSize: '0.85rem', color: '#64748B', marginTop: '0.15rem' }}>
                      {shipment.origin} → {shipment.destination}
                    </div>
                  </div>
                  <span
                    style={{
                      padding: '0.25rem 0.75rem',
                      borderRadius: '1rem',
                      fontSize: '0.75rem',
                      fontWeight: 600,
                      ...getStatusBadgeStyle(shipment.status),
                    }}
                  >
                    {shipment.status}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* Right Column: Open Disputes */}
          <div style={sectionCardStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
              <h3 style={{ fontSize: '1.1rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>Open Disputes</h3>
              <Link to="/admin/disputes" style={{ fontSize: '0.85rem', color: '#C8933A', fontWeight: 600, textDecoration: 'none' }}>
                View all
              </Link>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              {openDisputesList.map((dispute) => (
                <div
                  key={dispute.id}
                  style={{
                    backgroundColor: '#FEF2F2',
                    borderRadius: '0.75rem',
                    padding: '1.25rem',
                    border: '1px solid #FEE2E2',
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.35rem' }}>
                    <span style={{ fontWeight: 700, fontSize: '0.925rem', color: '#991B1B' }}>
                      {dispute.id} · {dispute.title}
                    </span>
                    <span style={{ fontSize: '0.8rem', color: '#991B1B', opacity: 0.8 }}>{dispute.date}</span>
                  </div>

                  <div style={{ fontSize: '0.85rem', color: '#B91C1C', marginBottom: '0.75rem' }}>
                    {dispute.parties} · {dispute.shipmentId}
                  </div>

                  <Link
                    to="/admin/disputes"
                    style={{
                      fontSize: '0.85rem',
                      fontWeight: 700,
                      color: '#DC2626',
                      textDecoration: 'none',
                      display: 'inline-block',
                    }}
                  >
                    Review dispute →
                  </Link>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}

// Inline Styles for Dashboard Metrics & Cards
const cardStyle: React.CSSProperties = {
  backgroundColor: '#FFFFFF',
  borderRadius: '0.85rem',
  padding: '1.25rem 1.5rem',
  boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
  border: '1px solid #E2E8F0',
  display: 'flex',
  flexDirection: 'column',
};

const iconStyle: React.CSSProperties = {
  width: '36px',
  height: '36px',
  borderRadius: '0.5rem',
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  fontSize: '1.1rem',
  marginBottom: '1rem',
};

const valStyle: React.CSSProperties = {
  fontSize: '1.75rem',
  fontWeight: 800,
  color: '#0F172A',
  lineHeight: 1.1,
  marginBottom: '0.35rem',
};

const labelStyle: React.CSSProperties = {
  fontSize: '0.825rem',
  color: '#64748B',
  fontWeight: 500,
};

const sectionCardStyle: React.CSSProperties = {
  backgroundColor: '#FFFFFF',
  borderRadius: '0.85rem',
  padding: '1.5rem',
  boxShadow: '0 1px 3px rgba(0,0,0,0.05)',
  border: '1px solid #E2E8F0',
};
