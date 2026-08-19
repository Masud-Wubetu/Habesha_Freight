import { useEffect, useState } from 'react';
import Sidebar from '../components/Sidebar';
import DashboardHeader from '../components/DashboardHeader';
import FindTruck from '../components/FindTruck';

type DashboardSection = 'dashboard' | 'find-truck' | 'requests' | 'deliveries' | 'history' | 'ratings' | 'profile';

interface Stat {
  label: string;
  value: string | number;
  icon: string;
  color: string;
}

interface Delivery {
  id: string;
  origin: string;
  destination: string;
  cargo: string;
  weight: string;
  status: 'In Transit' | 'Assigned' | 'In Progress';
  trucks?: number;
}

export default function Dashboard() {
  const [activeSection, setActiveSection] = useState<DashboardSection>('dashboard');
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const [loading, setLoading] = useState(true);

  const stats: Stat[] = [
    { label: 'Active Deliveries', value: 3, icon: '🚚', color: '#0B1F33' },
    { label: 'Pending Bids', value: 7, icon: '💰', color: '#C8933A' },
    { label: 'Completed', value: 24, icon: '✅', color: '#059669' },
    { label: 'Total Spent', value: 'ETB 184,500', icon: '💳', color: '#0B1F33' },
  ];

  const deliveries: Delivery[] = [
    {
      id: 'SHP-001',
      origin: 'Addis Ababa',
      destination: 'Dire Dawa',
      cargo: 'Electronics',
      weight: '8 tons',
      status: 'In Transit',
    },
    {
      id: 'SHP-002',
      origin: 'Adama',
      destination: 'Hawassa',
      cargo: 'Agricultural Produce',
      weight: '12 tons',
      status: 'Assigned',
    },
    {
      id: 'FR-003',
      origin: 'Addis Ababa',
      destination: 'Mekelle',
      cargo: 'Industrial Equipment',
      weight: '45 tons',
      trucks: 5,
      status: 'In Progress',
    },
  ];

  const quickActions = [
    { label: 'Find Single Truck', icon: '🚛' },
    { label: 'Find Fleet Company', icon: '🏢' },
    { label: 'View Requests', icon: '📋' },
    { label: 'Delivery History', icon: '🗂️' },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'In Transit':
        return '#0B1F33';
      case 'Assigned':
        return '#C8933A';
      case 'In Progress':
        return '#059669';
      default:
        return '#6b7280';
    }
  };

  const getSectionTitle = (section: DashboardSection) => {
    switch (section) {
      case 'dashboard': return 'Dashboard';
      case 'find-truck': return 'Find Truck';
      case 'requests': return 'Requests';
      case 'deliveries': return 'Deliveries';
      case 'history': return 'History';
      case 'ratings': return 'Ratings';
      case 'profile': return 'Profile';
      default: return 'Dashboard';
    }
  };

  useEffect(() => {
    setTimeout(() => setLoading(false), 500);
  }, []);

  if (loading) {
    return (
      <div className="dashboard-loading">
        <p>Loading dashboard...</p>
      </div>
    );
  }

  const renderContent = () => {
    switch (activeSection) {
      case 'dashboard':
        return (
          <>
            <div className="dashboard-stats-grid">
              {stats.map((stat) => (
                <div key={stat.label} className="stat-card">
                  <div className="stat-card-icon" style={{ backgroundColor: stat.color }}>
                    {stat.icon}
                  </div>
                  <div className="stat-card-content">
                    <span className="stat-card-value">{stat.value}</span>
                    <span className="stat-card-label">{stat.label}</span>
                  </div>
                </div>
              ))}
            </div>

            <div className="dashboard-content-grid">
              <div className="deliveries-card">
                <div className="deliveries-header">
                  <h2 className="deliveries-title">Active Deliveries</h2>
                  <button 
                    className="deliveries-view-all"
                    onClick={() => setActiveSection('deliveries')}
                  >
                    View all
                  </button>
                </div>

                <div className="deliveries-list">
                  {deliveries.map((delivery) => (
                    <div key={delivery.id} className="delivery-item">
                      <div className="delivery-header">
                        <span className="delivery-id">{delivery.id}</span>
                        <span className="delivery-route">
                          {delivery.origin} → {delivery.destination}
                        </span>
                      </div>
                      <div className="delivery-details">
                        <span className="delivery-cargo">
                          {delivery.cargo} · {delivery.weight}
                          {delivery.trucks && ` · ${delivery.trucks} trucks`}
                        </span>
                        <span
                          className="delivery-status"
                          style={{ backgroundColor: getStatusColor(delivery.status) }}
                        >
                          {delivery.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="quick-actions-card">
                <h2 className="quick-actions-title">Quick Actions</h2>
                <div className="quick-actions-list">
                  {quickActions.map((action) => (
                    <button key={action.label} className="quick-action-item">
                      <span className="quick-action-icon">{action.icon}</span>
                      <span className="quick-action-label">{action.label}</span>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </>
        );

      case 'deliveries':
        return (
          <div className="deliveries-page">
            <div className="deliveries-stats">
              <div className="delivery-stat-card">
                <span className="delivery-stat-value">12</span>
                <span className="delivery-stat-label">Total Deliveries</span>
              </div>
              <div className="delivery-stat-card">
                <span className="delivery-stat-value">3</span>
                <span className="delivery-stat-label">In Transit</span>
              </div>
              <div className="delivery-stat-card">
                <span className="delivery-stat-value">5</span>
                <span className="delivery-stat-label">Assigned</span>
              </div>
              <div className="delivery-stat-card">
                <span className="delivery-stat-value">4</span>
                <span className="delivery-stat-label">Completed</span>
              </div>
            </div>

            <div className="deliveries-full-list">
              {deliveries.map((delivery) => (
                <div key={delivery.id} className="delivery-full-item">
                  <div className="delivery-full-header">
                    <span className="delivery-full-id">{delivery.id}</span>
                    <span className="delivery-full-route">
                      {delivery.origin} → {delivery.destination}
                    </span>
                    <span
                      className="delivery-status"
                      style={{ backgroundColor: getStatusColor(delivery.status) }}
                    >
                      {delivery.status}
                    </span>
                  </div>
                  <div className="delivery-full-details">
                    <span>📦 {delivery.cargo}</span>
                    <span>⚖️ {delivery.weight}</span>
                    {delivery.trucks && <span>🚛 {delivery.trucks} trucks</span>}
                  </div>
                </div>
              ))}
            </div>
          </div>
        );

      case 'find-truck':
        return <FindTruck />;

      case 'requests':
        return (
          <div className="section-placeholder">
            <p>Requests section - Coming soon</p>
          </div>
        );

      case 'history':
        return (
          <div className="section-placeholder">
            <p>History section - Coming soon</p>
          </div>
        );

      case 'ratings':
        return (
          <div className="section-placeholder">
            <p>Ratings section - Coming soon</p>
          </div>
        );

      case 'profile':
        return (
          <div className="section-placeholder">
            <p>Profile section - Coming soon</p>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="dashboard-wrapper">
      <Sidebar 
        isOpen={isSidebarOpen} 
        onClose={() => setIsSidebarOpen(false)}
        activeSection={activeSection}
        onSectionChange={setActiveSection}
      />
      
      <div className="dashboard-main">
        <DashboardHeader 
          onMenuClick={() => setIsSidebarOpen(true)}
          title={getSectionTitle(activeSection)}
        />
        {renderContent()}
      </div>
    </div>
  );
}