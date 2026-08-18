import { ReactNode } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import { clearSession, getStoredUser } from '../services/authService';

interface AdminLayoutProps {
  children: ReactNode;
}

const adminNavItems = [
  { path: '/admin', label: 'Overview', icon: '📊' },
  { path: '/admin/users', label: 'Users', icon: '👥' },
  { path: '/admin/drivers', label: 'Drivers', icon: '🚛' },
  { path: '/admin/companies', label: 'Transport Companies', icon: '🏢' },
  { path: '/admin/vehicles', label: 'Vehicles', icon: '🚚' },
  { path: '/admin/deliveries', label: 'Deliveries', icon: '📦' },
  { path: '/admin/verification', label: 'Verification', icon: '✅' },
  { path: '/admin/payments', label: 'Payments / Escrow', icon: '💳' },
  { path: '/admin/disputes', label: 'Disputes', icon: '⚠️' },
  { path: '/admin/reports', label: 'Reports', icon: '📈' },
  { path: '/admin/audit-logs', label: 'Audit Logs', icon: '📋' },
];

export default function AdminLayout({ children }: AdminLayoutProps) {
  const navigate = useNavigate();
  const user = getStoredUser();

  const handleLogout = () => {
    clearSession();
    navigate('/login');
  };

  return (
    <div style={{ display: 'flex', minHeight: '100vh', backgroundColor: '#F4F6F9', fontFamily: 'DM Sans, sans-serif' }}>
      {/* Sidebar */}
      <aside
        style={{
          width: '260px',
          backgroundColor: '#071426',
          color: '#FFFFFF',
          display: 'flex',
          flexDirection: 'column',
          position: 'fixed',
          top: 0,
          bottom: 0,
          left: 0,
          zIndex: 100,
          transition: 'transform 0.3s ease',
        }}
      >
        {/* Brand */}
        <div style={{ padding: '1.5rem 1.5rem 1.25rem 1.5rem', borderBottom: '1px solid rgba(255,255,255,0.08)' }}>
          <Link to="/admin" style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
            <span style={{ color: '#C8933A', fontWeight: 700, fontSize: '1.35rem', letterSpacing: '-0.02em' }}>Habesha</span>
            <span style={{ color: '#FFFFFF', fontWeight: 700, fontSize: '1.35rem', letterSpacing: '-0.02em' }}>Freight</span>
          </Link>
          <div style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.5)', marginTop: '0.2rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            Admin Console
          </div>
        </div>

        {/* Navigation */}
        <nav style={{ flex: 1, padding: '1rem 0.75rem', overflowY: 'auto' }}>
          {adminNavItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.path === '/admin'}
              style={({ isActive }) => ({
                display: 'flex',
                alignItems: 'center',
                gap: '0.85rem',
                padding: '0.7rem 1rem',
                margin: '0.2rem 0',
                borderRadius: '0.5rem',
                textDecoration: 'none',
                fontSize: '0.925rem',
                fontWeight: isActive ? 600 : 400,
                color: isActive ? '#FFFFFF' : 'rgba(255,255,255,0.65)',
                backgroundColor: isActive ? '#1A2E46' : 'transparent',
                transition: 'all 0.2s ease',
              })}
            >
              <span style={{ fontSize: '1.1rem' }}>{item.icon}</span>
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        {/* Sidebar Footer / User Widget */}
        <div style={{ padding: '1.25rem', borderTop: '1px solid rgba(255,255,255,0.08)', backgroundColor: '#05101F' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
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
                fontSize: '0.875rem',
              }}
            >
              {(user?.full_name ?? 'Admin').split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase() || 'AD'}
            </div>
            <div>
              <div style={{ fontWeight: 600, fontSize: '0.875rem', color: '#FFFFFF' }}>{user?.full_name || 'Admin'}</div>
              <div style={{ fontSize: '0.75rem', color: 'rgba(255,255,255,0.5)' }}>Super Admin</div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            style={{
              background: 'none',
              border: 'none',
              color: 'rgba(255,255,255,0.5)',
              fontSize: '0.825rem',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '0.35rem',
              padding: 0,
            }}
          >
            ← Log Out
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div style={{ marginLeft: '260px', flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        {children}
      </div>
    </div>
  );
}
